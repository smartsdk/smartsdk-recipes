#!/bin/sh
(curl http://${ORION_EP}/v1/queryContext -s -S --header 'Content-Type: application/json' \
 --header 'Accept: application/json' --header 'fiware-service: Factory' --header 'fiware-servicepath: /robots' \
 -d @- | python -mjson.tool) <<EOF
{
    "entities": [
        {
            "type": "Robot",
            "isPattern": "false",
            "id": "Robot:robot1"
        }
    ]
}
EOF