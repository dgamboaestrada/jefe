#!/bin/bash
#
# loader.sh
#

libraries=$( ls "$DIR/libs/" )
for library in $libraries; do
    if [[ "$library" != "loader.sh" ]]; then
        source "$DIR/libs/$library"
    fi
done
