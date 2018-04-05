#!/bin/bash
# jefe-cli
# version 1.3.5
VERSION="1.3.5 development"

# Get root dir of the jefe-cli bash script
DIR="$(dirname "$(readlink -f "$0")")"
PROYECT_DIR="$PWD/.jefe"

# Load libraries
source $DIR/libs/loader.sh
source $DIR/services/loader.sh

# Load dotenv vars
if [[ -f  "$PROYECT_DIR/.env" ]]; then
    load_dotenv
fi

# Print jefe version.
--version(){
    puts "jefe version $VERSION"
}
# Alias of --version.
-v(){
    --version
}

# Print usage.
--help(){
    usage= cat <<EOF
jefe [-h] [--help] <command>

Arguments:
    -h, --help			Print Help (this message) and exit
    -v, --version		Print version information and exit

Commands:
    destroy			Remove containers of docker-compose and delete folder .jefe
    down			Stop and remove containers, networks, images, and volumes
    init			Create an empty jefe proyect and configure project
    itbash			Enter in bash mode iterative for the selected container
    logs			View output from containers
    permissions		Fix permisions of the proyect folder
    ps				List containers
    remove_adminer		Remove jefe_adminer container
    remove_nginx_proxy		Remove jefe_nginx_proxy container
    restart			Restart containers
    start_adminer		Create or start adminer container
    start_nginx_proxy		Create or start nginx_proxy container
    stop			Stop containers
    stop_adminer		Stop jefe_adminer container
    stop_nginx_proxy		Stop jefe_nginx_proxy container
    up				Create and start containers
    update			Upgrade jefe-cli

Settings commands:
    config_environments		Config environments
    create_folder_structure	Create folder structure of the proyect
    docker_env			Configure environments vars of docker
    remove_vhost 		Remove vhost to /etc/hosts file
    set_vhost			Add vhost to /etc/hosts file

Database commands:
    dump			Create dump of the database
    import_dump			Import dump of dumps folder of the proyect
    resetdb			Delete database and create empty database

Deploy commands
    deploy			Synchronize files to the selected environment
EOF
    usage_module=$DIR/modules/${project_type}/usage.txt
    if [[ -f  "$usage_module" ]]; then
        cat $usage_module
    fi
}
# Alias of --help.
-h(){
    --help
}


# Create an empty jefe proyect and configure project
init() {
    # Print logo.
    tput setaf 2;
    cat $DIR/logo.txt

    # Select type of project.
    flag=true
    while [ $flag = true ]; do
        puts "Select type of project" BLUE
        puts "1) Wordpress"
        puts "2) PHP(Nginx-MySQL)"
        puts "3) PHP(Apache-MySQL)"
        puts "4) Ruby On Rails"
        puts "Type the option (number) that you want(digit), followed by [ENTER]:" MAGENTA
        read option

        case $option in
            1)
                project_type=wordpress
                flag=false
                ;;
            2)
                project_type=php-nginx-mysql
                flag=false
                ;;
            3)
                project_type=php-apache-mysql
                flag=false
                ;;
            4)
                project_type=ruby-on-rails
                flag=false
                ;;
            *)
                puts "Wrong option" RED
                flag=true
                ;;
        esac
    done
    mkdir $PROYECT_DIR
    source $DIR/modules/${project_type}/jefe-cli.sh # Load tasks of module.
    cp $DIR/modules/${project_type}/docker-compose.yml $PROYECT_DIR/docker-compose.yml # Copy docker-compose configuration.
    cp $DIR/templates/environments.yaml $PROYECT_DIR/environments.yaml # Copy template jefe-cli.sh for custome tasks.
    docker_env
    load_dotenv
    sed -i "s/<PROJECT_NAME>/${project_name}/g" $PROYECT_DIR/docker-compose.yml
    create_folder_structure

    echo "Writing new values to .gitigonre..."
    if [[ ! -f  "./.gitignore" ]]; then
        cat $PROYECT_DIR/git.gitignore >> ./.gitignore
        puts "it already exists." YELLOW
    else
        while read line
        do
            if ! grep -q "$line"  "./.gitignore"; then
                echo "$line" >> ./.gitignore
            fi
        done < $PROYECT_DIR/git.gitignore
        puts "it already exists." YELLOW
    fi

    # Config environments.
    config_environments
}

# Configure environments vars of docker.
# It is necessary to implement.
docker_env() {
    echo 'Not implemented'
    exit 1
}

# Create dump of the database of the proyect.
# It is necessary to implement.
dump() {
    echo 'Not implemented'
    exit 1
}

# Import dump of dumps folder of the proyect.
# It is necessary to implement.
import_dump() {
    echo 'Not implemented'
    exit 1
}

# Delete database and create a empty database.
# It is necessary to implement.
resetdb() {
    echo 'Not implemented'
    exit 1
}

# Synchronize files to the selected environment
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

    load_settings_env $ENVIRONMENT
    excludes=$( echo $exclude | sed -e "s/;/ --exclude=/g" )
    cd $PROYECT_DIR
    if ! $TEST; then
        set -x #verbose on
        rsync -az --force --delete --progress --exclude=$excludes -e "ssh -p$port" "$project_root/." "${user}@${host}:$public_dir"
        set +x #verbose off
    else
        set -v #verbose on
        rsync --dry-run -az --force --delete --progress --exclude=$excludes -e "ssh -p${port}" "$project_root/." "${user}@${host}:$public_dir"
        set +v #verbose off
    fi
    cd ..
}

# Create folder structure of the project.
create_folder_structure() {
    puts "Make directory structure." BLUE
    echo "Creating app directory..."
    if [[ ! -d "./${project_root}" ]]; then
        mkdir ./${project_root}
        puts "done" GREEN
    else
        puts "it already exists." YELLOW
    fi

    echo "Creating dumps directory..."
    if [[ ! -d "./dumps" ]]; then
        mkdir "./dumps"
        touch "./dumps/.keep"
        puts "done" GREEN
    else
        puts "it already exists." YELLOW
    fi
}

# Add vhost to /etc/hosts file.
set_vhost(){
    remove_vhost # Remove old vhost.
    if [ ! "$( grep jefe-cli_wordpress /etc/hosts )" ]; then
        puts "Setting vhost..." BLUE
        hosts="$( echo "$VHOST" | tr ',' ' ' )"
        for host in $hosts; do
            sudo sh -c "echo '127.0.0.1     $host # ----- jefe-cli_$project_name' >> /etc/hosts"
        done
        puts "Done." GREEN
    fi
}

# Remove vhost to /etc/hosts file.
remove_vhost(){
    puts "Removing vhost..." BLUE
    sudo sh -c "sed -i '/# ----- jefe-cli_$project_name/d' /etc/hosts"
    puts "Done." GREEN
}

# Fix permisions of the proyect folder. Template function.
permissions(){
    puts "Setting permissions..." BLUE
    cd $PROYECT_DIR
    cd ..
    puts "Done." GREEN
}

# Remove containers of docker-compose and delete folder .jefe.
destroy() {
    puts "The containers and its volumes are destroyed also the folder .jefe will be destroyed." RED
    read -p "Are you sure?[Y/n] " -n 1 -r
    echo    # move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        down -v FORCE
        rm -rf "$PROYECT_DIR"
        puts "Proyect jefe was deleted." GREEN
    fi
}

# Create and start containers.
up() {
    usage= cat <<EOF
up [-h] [--help]

Arguments:
    --logs			View output from containers
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    DOCKER_COMPOSE_FILE="docker-compose.yml"
    LOGS=false

    # read the options
    OPTS=`getopt -o h --long logs,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --logs) LOGS=true ; shift ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    before_up
    start_nginx_proxy
    set_vhost
    permissions
    cd $PROYECT_DIR/
    docker-compose -f $DOCKER_COMPOSE_FILE -p $project_name up -d
    cd ..
    after_up

    if [ "$LOGS" = true ] ; then
        logs
    fi
}

after_up() {
    echo ""
    # Code to execute after up
}

before_up() {
    echo ""
    # Code to execute before up
}

# Stop containers.
stop() {
    remove_vhost
    cd $PROYECT_DIR/
    docker-compose -p $project_name stop
    cd ..
}

# Restart containers
restart() {
    cd $PROYECT_DIR/
    docker-compose -p $project_name restart
    cd ..
    set_vhost
    after_up
}

# Stop and remove containers, networks, images, and volumes.
down() {
    usage= cat <<EOF
jefe down [-v <option>] [--volumes <option>] [-h] [--help]

Arguments:
    -v, --volumes		Remove volumes of the proyect. Options force, not_force.
    -h, --help			Print Help (this message) and exit
EOF
    # set an initial value for the flag
    VOLUMES=false
    FORCE=false

    # read the options
    OPTS=`getopt -o v:h --long volumes,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -v|--volumes)
                VOLUMES=true
                 case "$2" in
                     force|FORCE) FORCE=true ; shift 2 ;;
                     not_force|NOT_FORCE) FORCE=false ; shift 2 ;;
                     *) puts "Invalid value for -v|--volume." RED ; exit 1 ; shift 2 ;;
                 esac ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    if $VOLUMES; then
        v="-v"
        if ! $FORCE; then
            puts "The volumes are destroyed." RED
            read -p "Are you sure?[Y/n] " -n 1 -r
            echo    # move to a new line
            if [[ ! $REPLY =~ ^[Yy]$ ]]
            then
                exit 1
            fi
        fi
    fi

    cd $PROYECT_DIR/
    puts "Down containers." BLUE
    docker-compose -p $project_name down $v
    puts "Done." GREEN
    cd ..
    remove_vhost
}

# Config environments.
config_environments() {
    puts "Config environments.." BLUE
    if [[ ! -f "$PROYECT_DIR/.environments.yaml" ]]; then
        cp "$DIR/modules/${project_type}/default.environments.yaml" $PROYECT_DIR/environments.yaml
    fi
    puts "Select editor to open environment settings file" MAGENTA
    puts "0) Vi"
    puts "1) Nano"
    puts "2) Skip"
    puts "Type the option (number) from the editor that you want, followed by [ENTER]:" MAGENTA
    read option
    case $option in
        0)
            vi $PROYECT_DIR/environments.yaml
            ;;
        1)
            nano $PROYECT_DIR/environments.yaml
            ;;
        2)
            ;;
        *)
            vi $PROYECT_DIR/environments.yaml
            ;;
    esac
}

# Configure docker-compose var env.
docker_env() {
    #     if [[ ! -f "$PROYECT_DIR/.env" ]]; then
    #         cp $PROYECT_DIR/default.env $PROYECT_DIR/.env
    #     fi
    echo "" > $PROYECT_DIR/.env
    set_dotenv PROJECT_TYPE $project_type
    puts "Write project name (default $project_type):" MAGENTA
    read proyect_name
    if [ -z $proyect_name ]; then
        set_dotenv PROJECT_NAME $project_type
    else
        set_dotenv PROJECT_NAME $proyect_name
    fi
    puts "Write project root, directory path from your proyect (default src):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv PROJECT_ROOT "../src"
    else
        set_dotenv PROJECT_ROOT "../$option"
    fi
    puts "Write vhost (default $proyect_name.local):" MAGENTA
    read option
    if [ -z $option ]; then
        set_dotenv VHOST "$proyect_name.local"
    else
        set_dotenv VHOST $option
    fi
}
# List containers.
ps() {
    cd $PROYECT_DIR
    docker-compose -p $project_name ps
    cd ..
}

# Enter in bash mode iterative for the selected container.
itbash() {
    usage= cat <<EOF
itbash [-c] [--container] [-h] [--help] <container_name>

Arguments:
    -c, --container		Set container name to execute bash iterative
    -h, --help			Print Help (this message) and exit
EOF
    # read the options
    OPTS=`getopt -o c:h --long container:,help -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -c|--container) container_name=$2 ; shift 2 ;;
            -h|--help) echo $usage ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    if [ -z "${container_name}" ]; then
        # Select contaner.
        # Display menu to select contaner name and return the seleted contanier.
        flag=true
        while [ $flag = true ]; do
            puts "Select container" BLUE
            puts "1) $APP_CONTAINER_NAME"
            puts "2) $DATABASE_CONTAINER_NAME"
            puts "Type the option (number) that you want(digit), followed by [ENTER]:" MAGENTA
            read option

            case $option in
                1)
                    container_name=$APP_CONTAINER_NAME
                    flag=false
                    ;;
                2)
                    container_name=$DATABASE_CONTAINER_NAME
                    flag=false
                    ;;
                *)
                    puts "Wrong option" RED
                    flag=true
                    ;;
            esac
        done
    fi
    docker exec -it $container_name bash
}


# View output from containers.
logs() {
    cd $PROYECT_DIR
    docker-compose -p $project_name logs -f
    cd ..
}

# Upgrade jefe cli
update() {
    branch_name=$(current_branch)
    git -C $DIR pull origin $branch_name
}

if [[ -f  "$PROYECT_DIR/.env" ]]; then
    source $DIR/modules/${project_type}/jefe-cli.sh # Load tasks of module.
    if [[ -f  "$PROYECT_DIR/jefe-cli.sh" ]]; then
        source $PROYECT_DIR/jefe-cli.sh
    fi
fi

# call arguments verbatim:
$@
