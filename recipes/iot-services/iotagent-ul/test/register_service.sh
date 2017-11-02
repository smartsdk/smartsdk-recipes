#/bin/bash

# Register
curl -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" http://${IOTA_EP}/iot/services -d '{
 "services": [
   {
     "apikey":      "4jggokgpepnvsb2uv4s40d59ov",
     "cbroker":     "http://orion:1026",
     "entity_type": "thing",
     "resource":    "/iot/d"
   }
 ]
}'

# Check
curl -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" http://${IOTA_EP}/iot/services | jq .



