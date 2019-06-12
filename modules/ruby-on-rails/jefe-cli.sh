#!/bin/bash
#
# ruby-on-rails jefe-cli.sh
#

# load container names vars
load_containers_names(){
    VOLUME_DATABASE_CONTAINER_NAME="${project_name}_db_data"
    DATABASE_CONTAINER_NAME="${project_name}_postgresql"
    APP_CONTAINER_NAME="${project_name}_rails"
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
}

# Create dump of the database of the proyect.
dump() {
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
            -h|--help) usage_dump ; exit 1 ; shift ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    if [[ "$ENVIRONMENT" == "docker" ]]; then
        docker exec -it $DATABASE_CONTAINER_NAME pg_dump -U ${dbuser} ${dbname} > "./dumps/${FILE_NAME}"
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

    if [[ "$ENVIRONMENT" == "docker" ]]; then
        docker exec -i $DATABASE_CONTAINER_NAME psql -U ${dbuser} ${dbname} < "./dumps/${FILE_NAME}"
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
        docker exec -it $APP_CONTAINER_NAME bash -c 'rails db:migrate VERSION=0;rails db:migrate'
    fi
}

# Execute the command "bundle install" in workdir folder.
bundle-install() {
  e=$1
  if [ -z "${e}" ]; then
    e="docker"
  fi

  if [[ "$e" == "docker" ]]; then
    docker exec -it ${project_name}_rails bash -c 'bundle install'
  fi
}

# Execute the command "rails db:migrate" in workdir folder. Run all rails database seeds
migrate() {
  e=$1
  if [ -z "${e}" ]; then
    e="docker"
  fi

  if [[ "$e" == "docker" ]]; then
    docker exec -it $APP_CONTAINER_NAME bash -c 'rails db:migrate'
  fi
}

# Execute the command "rails db:seed" in workdir folder. Run all rails database seeds
seed() {
  e=$1
  if [ -z "${e}" ]; then
    e="docker"
  fi

  if [[ "$e" == "docker" ]]; then
    docker exec -it $APP_CONTAINER_NAME bash -c 'rails db:seed'
  fi
}

# Execute the command "rubocop -R" in workdir folder.
rubocop() {
  e=$1
  if [ -z "${e}" ]; then
    e="docker"
  fi

  if [[ "$e" == "docker" ]]; then
    docker exec -it $APP_CONTAINER_NAME bash -c 'rubocop -R'
  fi
}

# Initialice
load_containers_names
