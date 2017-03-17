#!/bin/sh
if [[ "$1" != "" ]]; then
    host=$1
else
    host="localhost"
fi

if [[ "$2" != "" ]]; then
    port=$2
else
    port=8666
fi

curl $host:$port/STH/v1/contextEntities/type/Room/id/Room1/attributes/temperature?lastN=3 -s -S --header 'Accept: application/json' --header 'fiware-service: default' --header 'fiware-ServicePath: /' | python -mjson.tool
