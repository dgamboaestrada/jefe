#!/bin/bash
usage_module(){
    cat <<EOF
Commands for php-apache-mysql proyect:
    composer-install		Execute the command "composer install" in workdir folder
    composer-update		Execute the command "composer update" in workdir folder
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
