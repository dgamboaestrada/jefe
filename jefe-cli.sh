#!/bin/bash
# jefe-cli
# version 1.0.0

# Load utilities
source ~/.jefe/libs/utilities.sh

# Print jefe version.
--version(){
    puts "1.0.0" BLUE
}
# Alias of --version.
-v(){
    --version
}

# Print usage.
--help(){
    usage= cat <<EOF
jefe [-h] [--h]

Arguments:
    -h, --help			Print Help (this message) and exit
    -v, --version		Print version information and exit

Commands:
    init			Create an empty jefe proyect and configure project
    create_folder_structure	Create folder structure of the proyect
    set_vhost			Add vhost to /etc/hosts file
    remove_vhost 		Remove vhost to /etc/hosts file
    destroy			Remove containers of docker-compose and delete folder .jefe
    up				Create and start containers
    stop			Stop containers
    start			Start containers
    restart			Restart containers
    down			Stop and remove containers, networks, images, and volumes
    build			Build or rebuild services
    config_environments		Config environments
    docker_env			Configure docker-compose var env
    ps				List containers
    itbash			Enter in bash mode iterative for the selected container
    logs			View output from containers
    upgrade			Upgrade jefe-cli
EOF
    echo $usage
}
# Alias of --help.
-h(){
    --help
}


# Create an empty jefe proyect and configure project
init() {
    # Print logo.
    tput setaf 2;
    cat ~/.jefe/logo.txt

    # Select type of project.
    flag=true
    while [ $flag = true ]; do
        puts "Select type of project" BLUE
        puts "1) Wordpress"
#         puts "2) PHP-Nginx-Mysql"
#         puts "3) Ruby On Rails"
#         puts "4) Symfony 2.x"
#         puts "5) Laravel"
        puts "Type the option (number) that you want(digit), followed by [ENTER]:" MAGENTA
        read option

        case $option in
            1)
                project_type=wordpress
                flag=false
                ;;
#             0)
#                 project_type=php-nginx-mysql
#                 flag=false
#                 ;;
#             2)
#                 project_type=ruby-on-rails
#                 flag=false
#                 ;;
#             3)
#                 project_type=symfony
#                 flag=false
#                 ;;
#             4)
#                 project_type=laravel
#                 flag=false
#                 ;;
            *)
                puts "Wrong option" RED
                flag=true
                ;;
        esac
    done
    # Docker compose var env configuration.
    cp -r ~/.jefe/modules/$project_type .jefe
    if [[ -f  ".jefe/jefe-cli.sh" ]]; then
        source .jefe/jefe-cli.sh
    fi
    docker_env
    create_folder_structure

    echo "Writing new values to .gitigonre..."
    if [[ ! -f  "./.gitignore" ]]; then
        cat .jefe/git.gitignore >> ./.gitignore
        puts "it already exists." YELLOW
    else
        while read line
        do
            if ! grep -q "$line"  "./.gitignore"; then
                echo "$line" >> ./.gitignore
            fi
        done < .jefe/git.gitignore
        puts "it already exists." YELLOW
    fi

    # Config environments.
    config_environments
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
    if [ ! "$( grep jefe-cli_wordpress /etc/hosts )" ]; then
        puts "Setting vhost..." BLUE
        load_dotenv
        sudo sh -c "echo '127.0.0.1     $VHOST # ----- jefe-cli_$project_name' >> /etc/hosts"
        puts "Done." GREEN
    fi
}

# Remove vhost to /etc/hosts file.
remove_vhost(){
    puts "Removing vhost..." BLUE
    load_dotenv
    sudo sh -c "sed -i '/# ----- jefe-cli_$project_name/d' /etc/hosts"
    puts "Done." GREEN
}

# Remove jefe_nginx_proxy container.
remove_nginx_proxy(){
    # If jefe_nginx_proxy containr is running then stop
    if [ "$(docker ps | grep jefe_nginx_proxy)" ]; then
        stop_nginx_proxy
    fi
    puts "Removing jefe_nginx_proxy container..." BLUE
    docker rm jefe_nginx_proxy
    puts "Done." GREEN
}

# Create or start jefe_nginx_proxy container.
start_nginx_proxy(){
    # If jefe_nginx_proxy containr not exist then create
    if [ ! "$(docker ps -a | grep jefe_nginx_proxy)" ]; then
        puts "Running jefe_nginx_proxy container..." BLUE
        docker run -d --name jefe_nginx_proxy -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy:latest
        puts "Done." GREEN
    else
        puts "Starting jefe_nginx_proxy container..." BLUE
        docker start jefe_nginx_proxy
        puts "Done." GREEN
    fi
}

# Stop jefe_nginx_proxy container.
stop_nginx_proxy(){
    puts "Stoping jefe_nginx_proxy container..." BLUE
    docker stop jefe_nginx_proxy
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
        rm -rf ".jefe"
        puts "Proyect jefe was deleted." GREEN
    fi
}

# Create and start containers.
up() {
    # set an initial value for the flag
    DETACHED_MODE=""
    DOCKER_COMPOSE_FILE="docker-compose.yml"

    # read the options
    OPTS=`getopt -o dp --long detached-mode,production -n 'jefe' -- "$@"`
    if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -d|--detached-mode) DETACHED_MODE="-d" ; shift ;;
            -p|--production) DOCKER_COMPOSE_FILE="docker-compose-production.yml" ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    set_vhost
    load_dotenv
    cd .jefe/
    docker-compose -f $DOCKER_COMPOSE_FILE -p $project_name up $DETACHED_MODE
    cd ..
    remove_vhost
}

# Stop containers.
stop() {
    remove_vhost
    cd .jefe/
    docker-compose stop
    cd ..
}

# Start containers
start() {
    cd .jefe/
    docker-compose start
    cd ..
}

# Restart containers
restart() {
    cd .jefe/
    docker-compose restart
    cd ..
}

# Stop and remove containers, networks, images, and volumes.
#TODO creato usage to down command
down() {
    # set an initial value for the flag
    VOLUMES=false
    FORCE=false

    # read the options
    OPTS=`getopt -o v:h --long volumes,help: -n 'jefe' -- "$@"`
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
            -h|--help) echo "Coming soon." ; shift ;;
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

    load_dotenv
    cd .jefe/
    puts "Down containers." BLUE
    docker-compose -p $project_name down $v
    puts "Done." GREEN
    cd ..
    remove_vhost
}

# Build or rebuild services.
build() {
    cd .jefe/
    docker-compose build --no-cache
    cd ..
}

# Config environments.
config_environments() {
    load_dotenv
    puts "Config environments.." BLUE
    if [[ ! -f ".jefe/.environments.yaml" ]]; then
        cp .jefe/default.environments.yaml .jefe/environments.yaml
    fi
    puts "Select editor to open environment settings file" MAGENTA
    puts "0) Vi"
    puts "1) Nano"
    puts "2) Skip"
    puts "Type the option (number) from the editor that you want, followed by [ENTER]:" MAGENTA
    read option
    case $option in
        0)
            vi .jefe/environments.yaml
            ;;
        1)
            nano .jefe/environments.yaml
            ;;
        2)
            ;;
        *)
            vi .jefe/environments.yaml
            ;;
    esac
}

# Configure docker-compose var env.
docker_env() {
    #     if [[ ! -f ".jefe/.env" ]]; then
    #         cp .jefe/default.env .jefe/.env
    #     fi
    echo "" > .jefe/.env
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
    docker-compose ps
}

# Enter in bash mode iterative for the selected container.
#TODO Create usage to itbash
itbash() {
    cd .jefe/
    docker exec -it $1 bash
    cd ..
}

# View output from containers.
logs() {
    cd ./.jefe
    docker-compose logs -f
    cd ..
}

# Upgrade jefe cli
upgrade() {
    git -C ~/.jefe fetch origin
    git -C ~/.jefe pull origin master
    puts "Updated successfully." GREEN
}

if [[ -f  ".jefe/jefe-cli.sh" ]]; then
    source .jefe/jefe-cli.sh
fi

# call arguments verbatim:
$@
