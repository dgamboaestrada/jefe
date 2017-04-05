#!/bin/bash
#
# jefe.sh
#

# print text with color
out() {
#     Num  Colour    #define         R G B
#     0    black     COLOR_BLACK     0,0,0
#     1    red       COLOR_RED       1,0,0
#     2    green     COLOR_GREEN     0,1,0
#     3    yellow    COLOR_YELLOW    1,1,0
#     4    blue      COLOR_BLUE      0,0,1
#     5    magenta   COLOR_MAGENTA   1,0,1
#     6    cyan      COLOR_CYAN      0,1,1
#     7    white     COLOR_WHITE     1,1,1
    text=$1
    color=$2
    echo "$(tput setaf $color)$text $(tput sgr 0)"
}

version() {
    echo 0.1
}

init() {

    # Print logo
    tput setaf 2;
    cat ./jefe/logo.txt

    # create every folder needed

    out "Make directory structure." 4

    echo "Creating app directory..."
    if [[ ! -d "./app" ]]; then
        mkdir ./app
        out "done" 2
    else
        out "it already exists." 3
    fi

    echo "Creating database directory..."
    if [[ ! -d "./database" ]]; then
        mkdir ./database
        out "done" 2
    else
        out "it already exists." 3
    fi

    out "Setting configuration files." 4

    echo "Writing new values to .gitigonre..."
    if [[ ! -f  "./.gitignore" ]]; then
        cat ./jefe/git.gitignore >> ./.gitignore
        out "it already exists." 3
    else
        while read line
        do
            if ! grep -q "$line"  "./.gitignore"; then
                echo "$line" >> ./.gitignore
            fi
        done < ./jefe/git.gitignore
        out "it already exists." 3
    fi

    ###############################################################################################
    # Configure project
    ###############################################################################################
    flag=true
    project_type=php
    while [ $flag = true ]; do
        out "Configure project" 4
        out "Select project:" 5
        out "0) Default" 5
        out "1) CakePHP2.x" 5
        out "2) CakePHP3.x" 5
        out "3) Symfony" 5
        out "4) Laravel" 5
        out "5) Drupal" 5
        out "6) Prestashop" 5
        echo "Type the option (number) from the project that you want(digit), followed by [ENTER]:"
        read option
        case $option in
            0)
                project="default"
                flag=false
                ;;
            1)
                project="cakephp2.x"
                flag=false
                ;;
            2)
                project="cakephp"
                flag=false
                ;;
            3)
                project="symfony"
                flag=false
                ;;
            4)
                project="laravel"
                flag=false
                ;;
            5)
                project="drupal"
                flag=false
                ;;
            6)
                project="prestashop"
                flag=false
                ;;
            *)
                out "Wrong choice:$option" 1
                project=""
                flag=true
                ;;
        esac
    done
    cp ./jefe/nginx/vhosts/$project.conf ./jefe/nginx/default.conf

    # Docker compose var env configuration.
    docker_env

    # Config environments.
    config_environments
}

up() {
    cd ./jefe/
    fab up
    cd ..
}

stop() {
    cd ./jefe/
    fab stop
    cd ..
}

down() {
    cd ./jefe/
    fab up
    cd ..
}

bluid() {
    cd ./jefe/
    fab bluid
    cd ..
}

import_sql() {
    while getopts ":e:f:" option; do
        case "${option}" in
            e)
                e=${OPTARG}
                ;;
            f)
                f=${OPTARG}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${e}" ]; then
        e="docker"
    fi

    if [ -z "${f}" ]; then
        f="dump.sql"
    fi

    cd ./jefe/
    fab environment:${e},true import_sql:${f}
    cd ..
}

dumpdb() {
    while getopts ":e:f:" option; do
        case "${option}" in
            e)
                e=${OPTARG}
                ;;
            f)
                f=${OPTARG}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${e}" ]; then
        e="docker"
    fi

    if [ -z "${f}" ]; then
        f="dump.sql"
    fi

    cd ./jefe/
    fab environment:${e},true dumpdb:${f}
    cd ..
}

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

    cd ./jefe/
    fab environment:${e},true resetdb
    cd ..
}

drop_tables() {
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

    cd ./jefe/
    fab environment:${e},true drop_tables
    cd ..
}

deploy() {
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

    cd ./jefe/
    fab environment:${e},true deploy
    cd ..
}

backup() {
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

    cd ./jefe/
    fab environment:${e},true backup
    cd ..
}

execute() {
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

    cd ./jefe/
    fab environment:${e},true execute
    cd ..
}

it() {
    while getopts ":c:" option; do
        case "${option}" in
            c)
                c=${OPTARG}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${c}" ]; then
        c="docker-php_php"
    fi

    cd ./jefe/
    fab it:${c}
    cd ..
}

logs() {
    while getopts ":c:" option; do
        case "${option}" in
            c)
                c=${OPTARG}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${c}" ]; then
        c="docker-php_php"
    fi

    cd ./jefe/
    fab logs:${c}
    cd ..
}

# Docker compose var env configuration.
docker_env() {
    out "Docker compose var env configuration." 4
    if [[ ! -f "./jefe/.env" ]]; then
        cp ./jefe/default.env ./jefe/.env
    fi
    out "Write project name (default docker-$project_type):" 5
    read option
    if [ -z $option ]; then
        dotenv -f ./jefe/.env set PROJECT_NAME docker-$project_type
    else
        dotenv -f ./jefe/.env set PROJECT_NAME $option
    fi
    out "Write project root, directory path from your proyect (default app):" 5
    read option
    if [ -z $option ]; then
        dotenv -f ./jefe/.env set PROJECT_ROOT app
    else
        dotenv -f ./jefe/.env set PROJECT_ROOT $option
    fi
    out "Write database name (default docker):" 5
    read option
    if [ -z $option ]; then
        dotenv -f ./jefe/.env set DB_NAME docker
    else
        dotenv -f ./jefe/.env set DB_NAME $option
    fi
    out "Write database username (default docker):" 5
    read option
    if [ -z $option ]; then
        dotenv -f ./jefe/.env set DB_USERNAME docker
    else
        dotenv -f ./jefe/.env set DB_USERNAME $option
    fi
    out "Write database password (default docker):" 5
    read option
    if [ -z $option ]; then
        dotenv -f ./jefe/.env set DB_PASSWORD docker
    else
        dotenv -f ./jefe/.env set DB_PASSWORD $option
    fi
}

# Config environments.
config_environments() {
    out "Config environments.." 4
    if [[ ! -f "./jefe/.settings.yaml" ]]; then
        cp ./jefe/default.settings.yaml ./jefe/settings.yaml
    fi
    out "Select editor to open environment settings file" 5
    out "0) Vi" 5
    out "1) Nano" 5
    echo "Type the option (number) from the editor that you want, followed by [ENTER]:"
    read option
    case $option in
        0)
            vi ./jefe/settings.yaml
            ;;
        1)
            nano ./jefe/settings.yaml
            ;;
        *)
            vi ./jefe/settings.yaml
            ;;
    esac
}

help() {
    cd ./jefe/
    fab --list
    cd ..
}

# call arguments verbatim:
$@
