#!/bin/bash
#
# php-nginx-mysql jefe-cli.sh
#

# load container names vars
load_containers_names(){
    VOLUME_DATABASE_CONTAINER_NAME="${project_name}_db_data"
    DATABASE_CONTAINER_NAME="${project_name}_mysql"
    APP_CONTAINER_NAME="${project_name}_php"
    NGINX_CONTAINER_NAME="${project_name}_nginx"
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
        puts "4) CakePH3.x"
        puts "5) Symfony"
        puts "6) Symfony3.x"
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
                php_version='7.0-fpm'
                nginx_version='php-fpm'
                flag=false
                ;;
            2)
                framework=Laravel
                document_root='/var/www/html'
                php_version='7.0-fpm'
                nginx_version='php-fpm'
                flag=false
                ;;
            3)
                framework=CakePHP2.x
                document_root='/var/www/html/app/webroot'
                php_version='7.0-fpm'
                nginx_version='php-fpm'
                flag=false
                ;;
            4)
                framework=CakePHP3.x
                document_root='/var/www/html/webroot'
                php_version='7.0-fpm'
                nginx_version='php-fpm'
                flag=false
                ;;
            5)
                framework=Symfony
                document_root='/var/www/html/web'
                php_version='7.1-fpm'
                nginx_version='symfony-fpm'
                flag=false
                ;;
            6)
                framework=Symfony3
                document_root='/var/www/html/web'
                php_version='7.1-fpm'
                nginx_version='symfony-fpm'
                flag=false
                ;;
            *)
                puts "Wrong option" RED
                flag=true
                ;;
        esac
    done
    set_dotenv FRAMEWORK $framework
    set_dotenv DOCUMENT_ROOT $document_root
    set_dotenv PHP_VERSION $php_version
    set_dotenv NGINX_VERSION $nginx_version
    puts "Database root password is password" YELLOW
    set_dotenv DB_ROOT_PASSWORD "password"
}

# Fix permisions of the proyect folder
after_up(){
    puts "Setting permissions..." BLUE
    if id "www-data" >/dev/null 2>&1; then
        docker exec -it ${project_name}_php bash -c 'chgrp www-data -R .'
    fi
    puts "Done." GREEN
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
        docker exec -i $DATABASE_CONTAINER_NAME mysqldump -u ${dbuser} -p"${dbpassword}" ${dbname}  > "./dumps/${FILE_NAME}"
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
        docker exec -i $DATABASE_CONTAINER_NAME mysql -u ${dbuser} -p"${dbpassword}" ${dbname}  < "./dumps/${FILE_NAME}"
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
        docker exec -i ${project_name}_mysql mysql -u"${dbuser}" -p"${dbpassword}" -e "DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname}"
    else
        load_settings_env $ENVIRONMENT
        ssh ${user}@${host} "mysql -u${dbuser} -p\"${dbpassword}\" ${dbname} --host=${dbhost} -e \"DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname}\""
    fi
}

# Execute the command "composer install" in workdir folder
composer-install() {
    e=$1
    if [ -z "${e}" ]; then
        e="docker"
    fi
    if [[ "$e" == "docker" ]]; then
        docker exec -it ${project_name}_php bash -c 'composer install'
    else
        load_settings_env $e
        ssh ${user}@${host} -p $port "cd ${public_dir}/; composer install"
    fi
}

# Execute the command "composer update" in workdir folder
composer-update() {
    e=$1
    if [ -z "${e}" ]; then
        e="docker"
    fi
    if [[ "$e" == "docker" ]]; then
        docker exec -it ${project_name}_php bash -c 'composer update'
    else
        load_settings_env $e
        ssh ${user}@${host} -p $port "cd ${public_dir}/; composer update"
    fi
}

if [[ $FRAMEWORK == "Laravel" ]]; then
# Execute the command "php artisan migrate" in workdir folder. Running laravel migrations
migrate() {
        # set an initial value for the flag
        ENVIRONMENT="docker"
        MIGRATE_OPTION=""

        # read the options
        OPTS=`getopt -o e:fh --long environment:,force,refresh,refresh-seed,help -n 'jefe' -- "$@"`
        if [ $? != 0 ]; then puts "Invalid options." RED; exit 1; fi
        eval set -- "$OPTS"

        # extract options and their arguments into variables.
        while true ; do
            case "$1" in
                -e|--environment) ENVIRONMENT=$2 ; shift 2 ;;
                -f|--force) MIGRATE_OPTION=' --force' ; shift 2 ;;
                --refresh) MIGRATE_OPTION=':refresh' ; shift 2 ;;
                --refresh-seed) MIGRATE_OPTION=':refresh --seed' ; shift 2 ;;
                -h|--help) usage_migrate ; exit 1 ; shift ;;
                --) shift ; break ;;
                *) echo "Internal error!" ; exit 1 ;;
            esac
        done

        docker exec -it ${project_name}_php bash -c "php artisan migrate${MIGRATE_OPTION}"
    }

    # Execute the command "php artisan db:seed" in workdir folder. Run all laravel database seeds
    seed() {
        docker exec -it ${project_name}_php bash -c 'php artisan db:seed'
    }
fi

if [[ $FRAMEWORK == "Symfony" ]]; then
    # Fix permisions of the proyect folder
    after_up(){
        puts "Setting permissions..." BLUE
        docker exec -it ${project_name}_php bash -c 'php symfony cc'
        docker exec -it ${project_name}_php bash -c 'php symfony permissions'
        if id "www-data" >/dev/null 2>&1; then
            docker exec -it ${project_name}_php bash -c 'chgrp www-data -R .'
        fi
        puts "Done." GREEN
    }
    migrate() {
        echo 'Command not implemented yet'
        exit 1
    }
    seed() {
        echo 'Command not implemented yet'
        exit 1
    }
fi

# Initialice
load_containers_names
