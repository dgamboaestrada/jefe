#!/bin/bash
#
# services.sh
#

services=$( ls "$DIR/services/" )
for service in $services; do
    if [[ "$service" != "loader.sh" ]]; then
        source "$DIR/services/$service"
    fi
done
