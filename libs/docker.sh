#!/bin/bash
#
# docker.sh
#

# Create jefe-cli network if not exist.
jefe_cli_network(){
    if [ ! "$(docker network ls | grep jefe-cli)" ]; then
        puts "Creating jefe-cli network..." BLUE
        docker network create "jefe-cli"
        puts "Done." GREEN
    fi
}

