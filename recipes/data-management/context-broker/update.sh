#!/bin/bash
# Simple script to update something into Orion Context Broker
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

if [[ "$3" != "" ]]; then
    temp=$3
else
    temp=30.3
fi

curl $host:$port/v2/entities/Room1/attrs -s -S --header 'Content-Type: application/json' --header 'fiware-service: default' --header 'fiware-ServicePath: /' \
     -X PATCH -d @- <<EOF
{
  "temperature": {
    "value": $temp,
    "type": "Float"
  },
  "pressure": {
    "value": 767,
    "type": "Float"
  }
}
EOF
