#!/bin/sh
(curl http://${ORION_EP}/v1/updateContext -s -S --header 'Content-Type: application/json' \
 --header 'Accept: application/json' --header 'fiware-service: Factory' --header 'fiware-servicepath: /robots' \
 -d @- | python -mjson.tool) <<EOF
{
    "contextElements": [
        {
            "type": "Robot",
            "isPattern": "false",
            "id": "Robot:robot1",
            "attributes": [
            {
                "name": "Position",
                "type": "location",
                "value": "[18,3]"
            }
            ]
        }
    ],
    "updateAction": "UPDATE"
}
EOF
