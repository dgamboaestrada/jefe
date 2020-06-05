#!/bin/bash
usage_module(){
    cat <<EOF
Commands for ruby-on-rails proyect:
    bundle-install		Execute the command "bundle install" in workdir folder
    migrate			Execute the command "rails db:migrate" in workdir folder. Run all rails database seeds
    seed			Execute the command "rails db:seed" in workdir folder. Run all rails database seeds
    rubocop			Execute the command "rubocop -R" in workdir folder
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
    usage= cat <<EOF
resetdb [-e] [--environment] [-h] [--help]

Arguments:
    -e, --environment		Set environment to import dump. Default is docker
    -h, --help			Print Help (this message) and exit
EOF
}
