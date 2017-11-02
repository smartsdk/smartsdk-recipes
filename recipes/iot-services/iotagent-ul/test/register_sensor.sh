# Register sensor (device)
curl http://${IOTA_EP}/iot/devices \
-H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" \
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
curl -H "Content-type: application/json" -H "Fiware-Service: openiot" -H "Fiware-ServicePath: /" http://${IOTA_EP}/iot/devices | jq .