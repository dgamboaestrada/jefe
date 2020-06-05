#!/bin/bash
usage_module(){
    cat <<EOF
Commands for wordpress proyect:
    composer-install		Execute the command "composer install" in workdir folder
    composer-update		Execute the command "composer update" in workdir folder
    set-siteurl			Update siteurl and home option values in wordpress database. Default value of the VHOST configured
    debug			Define wordpress debug to true or false.
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
import-dump [-f] [--file] [-h] [--help]

Arguments:
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

usage_set_siteurl(){
    cat <<EOF
set-siteurl [-e] [--environment] [-H] [--host] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -H, --host			Host to set. Defualt value of the VHOST configured
    -h, --help			Print Help (this message) and exit
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

usage_debug(){
    cat <<EOF
debug [true] [false] [-h] [--help]

Arguments:
    false			Define wordpress debug to false
    true			Define wordpress debug to true
    -h, --help			Print Help (this message) and exit
EOF
}
