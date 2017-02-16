#!/bin/bash
# Simple script to insert something into Orion Context Broker
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

curl $host:$port/v2/entities -s -S --header 'Content-Type: application/json' -d @- <<EOF
{
  "id": "Room1",
  "type": "Room",
  "temperature": {
    "value": 23,
    "type": "Float"
  },
  "pressure": {
    "value": 720,
    "type": "Integer"
  }
}
EOF
