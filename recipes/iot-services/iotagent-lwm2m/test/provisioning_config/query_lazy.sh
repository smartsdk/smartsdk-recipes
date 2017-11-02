#!/bin/sh
(curl http://${ORION_EP}/v1/queryContext -s -S --header 'Content-Type: application/json' \
 --header 'Accept: application/json' --header 'fiware-service: Weather' --header 'fiware-servicepath: /baloons' \
 -d @- | python -mjson.tool) <<EOF
{
    "entities": [
        {
            "type": "WeatherBaloon",
            "isPattern": "false",
            "id": "weather1:WeatherBaloon"
        }
    ],
    "attributes" : [
        "Power Control"
    ]    
}
EOF