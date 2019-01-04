#!/bin/bash
usage_module(){
    cat <<EOF
Commands for php-nginx-mysql proyect:
    composer-install		Execute the command "composer install" in workdir folder
    composer-update		Execute the command "composer update" in workdir folder
    migrate			Running migration of the framework
    seed			Run all database seeds of the framework
EOF
}

usage_dump(){
    cat <<EOF
dump [-e] [--environment] [-f] [--file] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -f, --file			File name of dump. Default is dump.sql
    -h, --help			Print Help (this message) and exit
EOF
}

usage_import_dump(){
    cat <<EOF
import-dump [-e] [--environment] [-f] [--file] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -f, --file			File name of dump to import. Defualt is dump.sql
    -h, --help			Print Help (this message) and exit
EOF
}

usage_resetdb(){
    cat <<EOF
resetdb [-e] [--environment] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -h, --help			Print Help (this message) and exit
EOF
}

usage_migrate(){
    cat <<EOF
migrate [-e] [--environment] [-f] [--force] [--refresh] [--refresh-seed] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -f, --force			Force Migrations to run in production (migrate
        --refresh			Roll back all of your migrations and then execute the  migrate command
        --refresh-seed			Roll back all of your migrations, execute the  migrate command and run all database seed
    -h, --help			Print Help (this message) and exit
EOF
}
