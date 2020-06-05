#!/bin/bash
#
# adminer.sh
#

# Create or start adminer container.
start-adminer(){
    jefe_cli_network
    # If jefe_adminer containr not exist then create
    if [ ! $(docker ps -a --format "table {{.Names}}" | grep "^jefe_adminer") ]; then
        puts "Running jefe_adminer container..." BLUE
        docker run -d --name jefe_adminer -p 8080:8080 --network jefe-cli adminer:latest
        puts "Done." GREEN
    else
        puts "Starting jefe_adminer container..." BLUE
        docker start jefe_adminer
        puts "Done." GREEN
    fi
}

# Stop jefe_adminer container.
stop-adminer(){
    puts "Stoping jefe_adminer container..." BLUE
    # If jefe_adminer containr is running then stop
    if [ ! $(docker ps -a --format "table {{.Names}}" | grep "^jefe_adminer") ]; then
        docker stop jefe_adminer
        puts "Done." GREEN
    fi
}

# Remove jefe_adminer container.
remove-adminer(){
    stop_adminer
    puts "Removing jefe_adminer container..." BLUE
    docker rm jefe_adminer
    puts "Done." GREEN
}
