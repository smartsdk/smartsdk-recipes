#/bin/bash

# Register
curl -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" \
http://0.0.0.0:4041/iot/services -d '{
 "services": [
   {
     "apikey":      "4jggokgpepnvsb2uv4s40d59ov",
     "cbroker":     "http://0.0.0.0:1026",
     "entity_type": "thing",
     "resource":    "/iot/d"
   }
 ]
}'

# Check
curl -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" http://0.0.0.0:4041/iot/services | jq .

# Register sensor (device)
curl http://0.0.0.0:4041/iot/devices -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /"
-d '{
 "devices": [
   {
     "device_id":   "my_device_01",
     "entity_name": "my_entity_01",
     "entity_type": "thing",
     "protocol":    "PDI-IoTA-UltraLight",
     "timezone":    "Europe/Madrid",
     "attributes": [
       {
         "object_id": "t",
         "name":      "temperature",
         "type":      "int"
       },
       {
         "object_id": "l",
         "name":      "luminosity",
         "type":      "number"
       }
     ]
   }
 ]
}'

# Check
curl -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" http://0.0.0.0:4041/iot/devices | jq .

# Send from device
curl "http://0.0.0.0:7896/iot/d?k=4jggokgpepnvsb2uv4s40d59ov&i=my_device_01" -d 't|37#l|1200' -H "Content-type: text/plain"

# Check from Orion
curl http://0.0.0.0:1026/ngsi10/queryContext -H "Content-type: application/json" \ 
-H "Fiware-Service: openiot" -d '{
   "entities": [
       {
           "type": "",
           "id": "my_entity_01",
           "isPattern": "false"
       }
   ],
   "attributes": []
}'
