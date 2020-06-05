#!/bin/bash

usage(){
    cat <<EOF
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
    permissions			Fix permisions of the proyect folder
    ps				List containers
    remove-adminer		Remove jefe_adminer container
    remove-nginx-proxy		Remove jefe_nginx_proxy container
    restart			Restart containers
    start-adminer		Create or start adminer container
    start-nginx-proxy		Create or start nginx_proxy container
    stop			Stop containers
    stop-adminer		Stop jefe_adminer container
    stop-nginx-proxy		Stop jefe_nginx_proxy container
    up				Create and start containers
    update			Upgrade jefe-cli
    completions			Generate tab completion strings

Settings commands:
    config-environments		Config environments
    create-folder-structure	Create folder structure of the proyect
    docker-env			Configure environments vars of docker
    remove-vhost 		Remove vhost to /etc/hosts file
    set-vhost			Add vhost to /etc/hosts file

Database commands:
    dump			Create dump of the database
    import-dump			Import dump of dumps folder of the proyect
    resetdb			Delete database and create empty database

Deploy commands
    deploy			Synchronize files to the selected environment
EOF
}

usage_deploy(){
    cat <<EOF
ps [-e <environment>] [--environment <environment>] [-t] [--test] [-h] [--help]

Arguments:
    -e, --environment		Set environment to deployed
    -t, --test			Perform a test of the files to be synchronized
    -h, --help			Print Help (this message) and exit
EOF
}

usage_up(){
    cat <<EOF
up [-h] [--help]

Arguments:
    --logs			View output from containers
    -h, --help			Print Help (this message) and exit
EOF
}

usage_down(){
    cat <<EOF
jefe down [-v <option>] [--volumes <option>] [-h] [--help]

Arguments:
    -v, --volumes		Remove volumes of the proyect. Options force, not_force.
    -h, --help			Print Help (this message) and exit
EOF
}

usage_itbash(){
    cat <<EOF
itbash [-c] [--container] [-h] [--help] <container_name>

Arguments:
    -c, --container		Set container name to execute bash iterative
    -h, --help			Print Help (this message) and exit
EOF
}
