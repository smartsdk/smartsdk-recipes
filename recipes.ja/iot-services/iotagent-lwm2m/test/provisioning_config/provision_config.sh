#!/bin/sh
(curl ${IOTA_EP}/iot/services -s -S --header 'Content-Type: application/json' \
  --header 'Accept: application/json' --header 'fiware-service: Weather' --header 'fiware-servicepath: /baloons' \
  -d @- | python -mjson.tool) <<EOF
{
  "services": [
    {
      "resource": "/weatherBaloon",
      "apikey": "",
      "type": "WeatherBaloon",
      "commands": [],
      "lazy": [
        {
          "name": "Longitude",
          "type": "double"
        },
        {
          "name": "Latitude",
          "type": "double"
        },
        {
          "name": "Temperature Sensor",
          "type": "degrees"
        }
      ],
      "active": [
        {
          "name": "Power Control",
          "type": "Boolean"
        }
      ]
    }
  ]
}
EOF
