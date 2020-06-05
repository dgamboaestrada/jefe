#!/bin/bash
#
# php-apache-mysql jefe-cli.sh

# load container names vars
load_containers_names(){
    VOLUME_DATABASE_CONTAINER_NAME="${project_name}_db_data"
    DATABASE_CONTAINER_NAME="${project_name}_db"
    APP_CONTAINER_NAME="${project_name}_php"
}

# Configure environments vars of module for docker image.
module_docker_env() {
    puts "Write database name (default $proyect_name):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv DB_NAME "$proyect_name"
    else
        set_dotenv DB_NAME $option
    fi
    puts "Write database username (default $proyect_name):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv DB_USER "$proyect_name"
    else
        set_dotenv DB_USER $option
    fi
    puts "Write database password (default password):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv DB_PASSWORD "password"
    else
        set_dotenv DB_PASSWORD $option
    fi
    puts "Select framework:" MAGENTA
    flag=true
    while [ $flag = true ]; do
        puts "1) None"
        puts "2) Laravel"
        puts "3) CakePHP2.x"
        puts "4) CakePHP3.x"
        puts "5) Symfony"
        puts "Type the option (number) that you want(digit), followed by [ENTER]:"
        read option

        case $option in
            1)
                framework=None
                puts "Write DocumentRoot (default /var/www/html):" MAGENTA
                read option
                if [ -z $option ]; then
                    document_root='/var/www/html'
                else
                    document_root=$option
                fi
                flag=false
                ;;
            2)
                framework=Laravel
                document_root='/var/www/html'
                flag=false
                ;;
            3)
                framework=CakePHP2.x
                document_root='/var/www/html/app/webroot'
                flag=false
                ;;
            4)
                framework=CakePHP3.x
                document_root='/var/www/html/webroot'
                flag=false
                ;;
            5)
                framework=Symfony
                document_root='/var/www/html/web'
                flag=false
                ;;
            *)
                puts "Wrong option" RED
                flag=true
                ;;
        esac
    done
    set_dotenv FRAMEWORK $framework
    puts "Database root password is password" YELLOW
    set_dotenv DB_ROOT_PASSWORD "password"
}

# Add vhost of /etc/hosts file
set-vhost(){
    remove-vhost # Remove old vhost
    if [ ! "$( grep jefe-cli_wordpress /etc/hosts )" ]; then
        puts "Setting vhost..." BLUE
        load_dotenv
        hosts="$( echo "$VHOST" | tr ',' ' ' )"
        for host in $hosts; do
            sudo sh -c "echo '127.0.0.1     $host # ----- jefe-cli_$project_name' >> /etc/hosts"
            sudo sh -c "echo '127.0.0.1     phpmyadmin.$host # ----- jefe-cli_$project_name' >> /etc/hosts"
        done
        puts "Done." GREEN
    fi
}

# Fix permisions of the proyect folder
permissions(){
    load_dotenv
    puts "Setting permissions..." BLUE
    cd $PROYECT_DIR
        if id "www-data" >/dev/null 2>&1; then
            sudo chown -R "$USER:www-data" $project_root
        fi
    cd ..
    puts "Done." GREEN
}

# Create dump of the database of the proyect.
dump() {
    # set an initial value
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
            -h|--help) usage_dump ; exit 1 ; shift ;;
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
import-dump() {
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
            -h|--help) usage_import_dump ; exit 1 ; shift ;;
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

# Delete database and create empty database.
resetdb() {
    # set an initial value for the flag
    ENVIRONMENT="docker"

    # read the options
    OPTS=`getopt -o e:h --long environment:,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -e|--environment) ENVIRONMENT=$2 ; shift 2 ;;
            -h|--help) usage_resetdb ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    if [[ "$ENVIRONMENT" == "docker" ]]; then
        load_dotenv
        docker exec -i ${project_name}_db mysql -u"${dbuser}" -p"${dbpassword}" -e "DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname}"
    else
        load_settings_env $ENVIRONMENT
        ssh ${user}@${host} "mysql -u${dbuser} -p\"${dbpassword}\" ${dbname} --host=${dbhost} -e \"DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname}\""
    fi
}

composer-install() {
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

composer-update() {
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

# Initialice
load_containers_names
