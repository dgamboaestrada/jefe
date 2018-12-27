#!/bin/bash
#
# nginx-proxy.sh
#

# Create or start nginx_proxy container.
start-nginx-proxy(){
    jefe_cli_network
    # If jefe_nginx_proxy containr not exist then create
    if [ ! $(docker ps -a --format "table {{.Names}}" | grep "^jefe_nginx_proxy") ]; then
        puts "Running jefe_nginx_proxy container..." BLUE
        docker run -d --name jefe_nginx_proxy -p 80:80 --network jefe-cli -v /var/run/docker.sock:/tmp/docker.sock:ro -v ~/.jefe-cli/templates/nginx-proxy-settings.conf:/etc/nginx/conf.d/proxy-settings.conf:ro jwilder/nginx-proxy:latest
        puts "Done." GREEN
    else
        puts "Starting jefe_nginx_proxy container..." BLUE
        docker start jefe_nginx_proxy
        puts "Done." GREEN
    fi
}

# Stop jefe_nginx_proxy container.
stop-nginx-proxy(){
    # If jefe_nginx_proxy containr is running then stop
    puts "Stoping jefe_nginx_proxy container..." BLUE
    if [ ! $(docker ps -a --format "table {{.Names}}" | grep "^jefe_nginx_proxy") ]; then
        docker stop jefe_nginx_proxy
    fi
    puts "Done." GREEN
}

# Remove jefe_nginx_proxy container.
remove-nginx-proxy(){
    stop_nginx_proxy
    puts "Removing jefe_nginx_proxy container..." BLUE
    docker rm jefe_nginx_proxy
    puts "Done." GREEN
}

