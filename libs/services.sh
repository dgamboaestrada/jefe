#!/bin/bash
#
# services.sh
#

# Create or start nginx_proxy container.
start_nginx_proxy(){
    if [ ! "$(docker network ls | grep jefe-cli)" ]; then
        puts "Creating jefe-cli network..." BLUE
        docker network create "jefe-cli"
        puts "Done." GREEN
    fi
    # If jefe_nginx_proxy containr not exist then create
    if [ ! $(docker ps -a --format "table {{.Names}}" | grep "^jefe_nginx_proxy") ]; then
        puts "Running jefe_nginx_proxy container..." BLUE
        docker run -d --name jefe_nginx_proxy -p 80:80 --network jefe-cli -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy:latest
        puts "Done." GREEN
    else
        puts "Starting jefe_nginx_proxy container..." BLUE
        docker start jefe_nginx_proxy
        puts "Done." GREEN
    fi
}

# Stop jefe_nginx_proxy container.
stop_nginx_proxy(){
    puts "Stoping jefe_nginx_proxy container..." BLUE
    docker stop jefe_nginx_proxy
    puts "Done." GREEN
}

# Remove jefe_nginx_proxy container.
remove_nginx_proxy(){
    # If jefe_nginx_proxy containr is running then stop
    if [ ! $(docker ps -a --format "table {{.Names}}" | grep "^jefe_nginx_proxy") ]; then
        stop_nginx_proxy
    fi
    puts "Removing jefe_nginx_proxy container..." BLUE
    docker rm jefe_nginx_proxy
    puts "Done." GREEN
}

