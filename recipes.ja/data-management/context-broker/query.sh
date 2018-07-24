#!/bin/bash
# Simple script to query Orion Context Broker
if [[ "$1" != "" ]]; then
    host=$1
else
    host="localhost"
fi

if [[ "$2" != "" ]]; then
    port=$2
else
    port=1026
fi

echo "curl ${host}:/${port}"
curl $host:$port/version
curl $host:$port/v2/entities -s -S --header 'Accept: application/json' --header 'fiware-service: default' --header 'fiware-ServicePath: /' | python -mjson.tool
