#!/bin/sh

(curl ${IOTA_EP}/iot/devices -s -S --header 'Content-Type: application/json' \
  --header 'Accept: application/json' --header 'fiware-service: Factory' --header 'fiware-servicepath: /robots' \
  -d @- | python -mjson.tool) <<EOF
{
  "devices": [
      {
        "device_id": "robot1",
        "entity_type": "Robot",
        "attributes": [
          {
            "name": "Battery",
            "type": "number"
          }
        ],
        "lazy": [
          {
            "name": "Message",
            "type": "string"
          }
        ],
        "commands": [
          {
            "name": "Position",
            "type": "location"
          }
        ],
      "internal_attributes": {
        "lwm2mResourceMapping": {
          "Battery" : {
            "objectType": 7392,
            "objectInstance": 0,
            "objectResource": 1
          },
          "Message" : {
            "objectType": 7392,
            "objectInstance": 0,
            "objectResource": 2
          },
          "Position" : {
            "objectType": 7392,
            "objectInstance": 0,
            "objectResource": 3
          }
        }
      }
    }
  ]
}
EOF