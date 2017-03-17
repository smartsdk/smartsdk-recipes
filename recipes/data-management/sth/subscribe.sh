#!/bin/sh
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

curl $host:$port/v1/subscribeContext -s -S \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'FIWARE-Service: default' -H 'FIWARE-ServicePath: /' \
  -d @- <<EOF
{
    "entities": [
        {
            "type": "Room",
            "id": "Room1"
        }
    ],
    "attributes": [
        "temperature",
        "pressure"
    ],
    "reference": "http://comet:8666/notify",
    "notifyConditions": [
        {
            "type": "ONCHANGE",
            "condValues": [
                "temperature",
                "pressure"
            ]
        }
    ]
}
EOF
