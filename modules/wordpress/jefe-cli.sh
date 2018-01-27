#!/bin/bash
#
# wordpress jefe-cli.sh

# Load utilities
source ~/.jefe-cli/libs/utilities.sh

# Configure environments vars of docker.
docker_env() {
    puts "Docker compose var env configuration." BLUE
    echo "" > .jefe/.env
    set_dotenv PROJECT_TYPE $project_type
    puts "Write project name (default $project_type):" MAGENTA
    read proyect_name
    if [ -z $proyect_name ]; then
        set_dotenv PROJECT_NAME $project_type
        proyect_name=$project_type
    else
        set_dotenv PROJECT_NAME $proyect_name
    fi
    puts "Write project root, directory path from your proyect (default src):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv PROJECT_ROOT "src/"
    else
        set_dotenv PROJECT_ROOT "${option}/"
    fi
    puts "Write vhost (default $proyect_name.local):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv VHOST "$proyect_name.local"
    else
        set_dotenv VHOST $option
    fi
    puts "Write environment var name, (default local):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv ENVIRONMENT "local"
    else
        set_dotenv ENVIRONMENT "$option"
    fi
    puts "Write wordpress version, (default latest):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv WORDPRESS_VERSION "latest"
    else
        set_dotenv WORDPRESS_VERSION "$option"
    fi
    puts "Write wordpress table prefix (default wp_):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv WORDPRESS_TABLE_PREFIX "wp_"
    else
        set_dotenv WORDPRESS_TABLE_PREFIX $option
    fi

    load_dotenv
    puts "Database root password is password" YELLOW
    set_dotenv DB_ROOT_PASSWORD "password"
    puts "Database name is wordpress" YELLOW
    set_dotenv DB_NAME "wordpress"
    puts "Database user is wordpress" YELLOW
    set_dotenv DB_USER "wordpress"
    puts "Database wordpress password is wordpress" YELLOW
    set_dotenv DB_PASSWORD "wordpress"
    puts "phpMyAdmin url: phpmyadmin.$vhost" YELLOW
    # Set nginx port to 80
    set_dotenv NGINX_PORT "80"
}

# Add vhost of /etc/hosts file
set_vhost(){
    if [ ! "$( grep jefe-cli_wordpress /etc/hosts )" ]; then
        puts "Setting vhost..." BLUE
        load_dotenv
        sudo sh -c "echo '127.0.0.1     $VHOST # ----- jefe-cli_$project_name' >> /etc/hosts"
        sudo sh -c "echo '127.0.0.1     phpmyadmin.$VHOST # ----- jefe-cli_$project_name' >> /etc/hosts"
        puts "Done." GREEN
    fi
}

# load container names vars
load_containers_names(){
    load_dotenv
    volume_database_container_name="${project_name}_db_data"
    database_container_name="${project_name}_db"
    wordpress_container_name="${project_name}_wordpress"
    phpmyadmin_container_name="${project_name}_phpmyadmin"
}

# Create and start containers.
up(){
    load_containers_names
    WORDPRESS_VERSION=$( get_dotenv "WORDPRESS_VERSION" )
    WORDPRESS_TABLE_PREFIX=$( get_dotenv "WORDPRESS_TABLE_PREFIX" )
    WORDPRESS_VERSION=$( get_dotenv "WORDPRESS_VERSION" )

    set_vhost
    start_nginx_proxy
    if [ ! "$(docker volume ls | grep $volume_database_container_name)" ]; then
        puts "Creating database volume..." BLUE
        docker volume create $volume_database_container_name
        puts "Done." GREEN
    fi
    if [ ! "$(docker ps -a | grep $database_container_name)" ]; then
        puts "Running mysql container..." BLUE
        docker run --name $database_container_name -v $volume_database_container_name:/var/lib/mysql -e MYSQL_ROOT_PASSWORD="password" -e MYSQL_DATABASE="wordpress" -e MYSQL_USER="wordpress" -e MYSQL_PASSWORD="wordpress" -d mysql:$WORDPRESS_VERSION
        puts "Done." GREEN
    else
        puts "Starting mysql container..." BLUE
        docker start $database_container_name
        puts "Done." GREEN
    fi

    if [ ! "$(docker ps -a | grep $wordpress_container_name)" ]; then
        puts "Running wordpress container..." BLUE
        docker run --name $wordpress_container_name --link $database_container_name:"${project_name}_db" -e VIRTUAL_HOST="$VHOST" -e WORDPRESS_DB_HOST="${project_name}_db:3306" -e WORDPRESS_DB_USER="wordpress" -e WORDPRESS_DB_PASSWORD="wordpress" -e WORDPRESS_TABLE_PREFIX="${WORDPRESS_TABLE_PREFIX}" -v "${PROJECT_ROOT}:/var/www/html/wp-content" -d wordpress:$WORDPRESS_VERSION
        puts "Done." GREEN
    else
        puts "Starting wordpress container..." BLUE
        docker start $wordpress_container_name
        puts "Done." GREEN
    fi

    if [ ! "$(docker ps -a | grep $phpmyadmin_container_name)" ]; then
        puts "Running phpmyadmin container..." BLUE
        docker run --name $phpmyadmin_container_name --link $database_container_name:"${project_name}_db" -e VIRTUAL_HOST="phpmyadmin.${VHOST}" -e PMA_HOST="${project_name}_db" -d phpmyadmin/phpmyadmin
        puts "Done." GREEN
    else
        puts "Starting phpmyadmin container..." BLUE
        docker start $phpmyadmin_container_name
        puts "Done." GREEN
    fi
}

# Stop containers.
stop(){
    load_containers_names
    puts "Stoping containers..." BLUE
    docker stop $wordpress_container_name $database_container_name $phpmyadmin_container_name
    puts "Done." GREEN
    remove_vhost
}

# Restart containers.
restart(){
    load_containers_names
    puts "Restarting containers..." BLUE
    docker restart $wordpress_container_name $database_container_name $phpmyadmin_container_name
    puts "Done." GREEN
    remove_vhost
}

# Remove containers and volumes.
down(){
    usage= cat <<EOF
ps [-v <option>] [--volumes <option>] [-h] [--help]

Arguments:
    -v, --volumes		Specifies if the volumes are removed. Options remove, not_remove.
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    VOLUMES=false
    VOLUMES_RM=false

    # read the options
    OPTS=`getopt -o v:h --long volumes:,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -v|--volumes)
                VOLUMES=true
                 case "$2" in
                     remove|REMOVE) VOLUMES_RM=true ; shift 2 ;;
                     not_remove|NOT_REMOVE) VOLUMES_RM=false ; shift 2 ;;
                     *) puts "Invalid value for -v|--volume." RED ; exit 1 ; shift 2 ;;
                 esac ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    load_containers_names
    puts "Removing containers..." BLUE
    echo "docker rm $v $wordpress_container_name $database_container_name $phpmyadmin_container_name"
    docker rm $v $wordpress_container_name $database_container_name $phpmyadmin_container_name
    puts "Done." GREEN

    if ! $VOLUMES; then
        puts "You want to remove the volumes?" RED
        read -p "Are you sure?[Y/n] " -n 1 -r
        echo    # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]] ; then
            VOLUMES_RM=true
        fi
    fi

    if $VOLUMES_RM; then
        puts "Removing volumes..." BLUE
        docker volume rm $volume_database_container_name
        puts "Done." GREEN
    fi

    remove_vhost
}

# Create dump of the database of the proyect.
dump() {
    usage= cat <<EOF
dump [-e] [--environment] [-f] [--file] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -f, --file			File name of dump. Default is dump.sql
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    ENVIRONMENT="docker"
    FILE_NAME="dump.sql"

    # read the options
    OPTS=`getopt -o e:f:h --long environment:,file:,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -e|--environment) ENVIRONMENT=$2 ; shift 2 ;;
            -f|--file) FILE_NAME=$2 ; shift 2 ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    load_dotenv
    if [[ "$ENVIRONMENT" == "docker" ]]; then
        docker exec -i ${project_name}_db mysqldump -u ${dbuser} -p"${dbpassword}" ${dbname}  > "./dumps/${FILE_NAME}"
    else
        load_settings_env $ENVIRONMENT
        ssh ${user}@${host} "mysqldump -u${dbuser} -p\"${dbpassword}\" ${dbname} --host=${dbhost} > ./dumps/${FILE_NAME}"
    fi
}

# Import dump of dumps folder of the proyect.
import_dump() {
    usage= cat <<EOF
import_dump [-e] [--environment] [-f] [--file] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -f, --file			File name of dump to import. Defualt is dump.sql
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    ENVIRONMENT="docker"
    FILE_NAME="dump.sql"

    # read the options
    OPTS=`getopt -o e:f:h --long environment:,file:,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -e|--environment) ENVIRONMENT=$2 ; shift 2 ;;
            -f|--file) FILE_NAME=$2 ; shift 2 ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    load_dotenv
    if [[ "$ENVIRONMENT" == "docker" ]]; then
        docker exec -i ${project_name}_db mysql -u ${dbuser} -p"${dbpassword}" ${dbname}  < "./dumps/${FILE_NAME}"
    else
        load_settings_env $ENVIRONMENT
        ssh ${user}@${host} "mysql -u${dbuser} -p\"${dbpassword}\" ${dbname} --host=${dbhost} < ./dumps/${FILE_NAME}"
    fi
}

# Update siteurl option value in wordpress database.
set_siteurl() {
    usage= cat <<EOF
set_siteurl [-e] [--environment] [-H] [--host] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -H, --host			Host to set. Defualt value of the VHOST configured
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    load_dotenv
    ENVIRONMENT="docker"
    HOST="$VHOST"

    # read the options
    OPTS=`getopt -o e:H:h --long environment:,host:,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -e|--environment) ENVIRONMENT=$2 ; shift 2 ;;
            -H|--host) HOST=$2 ; shift 2 ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    WORDPRESS_TABLE_PREFIX=$( get_dotenv "WORDPRESS_TABLE_PREFIX" )
    if [[ "$ENVIRONMENT" == "docker" ]]; then
        docker exec -i ${project_name}_db mysql -u ${dbuser} -p"${dbpassword}" ${dbname} -e "UPDATE ${WORDPRESS_TABLE_PREFIX}options SET option_value='http://${HOST}' WHERE option_name like 'siteurl'"
        docker exec -i ${project_name}_db mysql -u ${dbuser} -p"${dbpassword}" ${dbname} -e "UPDATE ${WORDPRESS_TABLE_PREFIX}options SET option_value='http://${HOST}' WHERE option_name like 'home'"
    else
        load_settings_env $ENVIRONMENT
        ssh ${user}@${host} "mysql -u${dbuser} -p\"${dbpassword}\" ${dbname} --host=${dbhost} < ./dumps/${FILE_NAME}"
    fi
}

# Delete database and create empty database.
resetdb() {
    while getopts ":e:" option; do
        case "${option}" in
            e)
                e=${OPTARG}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${e}" ]; then
        e="docker"
    fi

    if [[ "$e" == "docker" ]]; then
        load_dotenv
        docker exec -i ${project_name}_db mysql -u"${dbuser}" -p"${dbpassword}" -e "DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname}"
    else
        load_settings_env $e
        ssh ${user}@${host} "mysql -u${dbuser} -p\"${dbpassword}\" ${dbname} --host=${dbhost} -e \"DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname}\""
    fi
}

# Synchronize files to the selected environment.
deploy() {
    usage= cat <<EOF
ps [-e <environment>] [--environment <environment>] [-t] [--test] [-h] [--help]

Arguments:
    -e, --environment		Set environment to deployed
    -t, --test			Perform a test of the files to be synchronized
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    ENVIRONMENT=""
    TEST=false

    # read the options
    OPTS=`getopt -o e:th --long environment:,test,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -e|--environment) ENVIRONMENT=$2 ; shift 2 ;;
            -t|--test) TEST=true ; shift ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    load_dotenv
    load_settings_env $ENVIRONMENT
    excludes=$( echo $exclude | sed -e "s/;/ --exclude=/g" )
    cd .jefe
    if ! $TEST; then
        set -x #verbose on
        rsync -az --force --delete --progress --exclude="uploads/" --exclude="upgrade/" --exclude=$excludes -e "ssh -p$port" "$project_root/." "${user}@${host}:$public_dir"
        set +x #verbose off
    else
        set -v #verbose on
        rsync --dry-run -az --force --delete --progress --exclude="uploads/" --exclude="upgrade/" --exclude=$excludes -e "ssh -p${port}" "$project_root/." "${user}@${host}:$public_dir"
        set +v #verbose off
    fi
    cd ..
}

# Execute the command "composer install" in workdir folder.
composer_install() {
    e=$1
    if [ -z "${e}" ]; then
        e="docker"
    fi
    if [[ "$e" == "docker" ]]; then
        load_dotenv
        docker exec -it ${project_name}_php bash -c 'composer install'
    else
        load_settings_env $e
        ssh ${user}@${host} -p $port "cd ${public_dir}/; composer install"
    fi
}

# Execute the command "composer update" in workdir folder.
composer_update() {
    e=$1
    if [ -z "${e}" ]; then
        e="docker"
    fi
    if [[ "$e" == "docker" ]]; then
        load_dotenv
        docker exec -it ${project_name}_php bash -c 'composer update'
    else
        load_settings_env $e
        ssh ${user}@${host} -p $port "cd ${public_dir}/; composer update"
    fi
}
