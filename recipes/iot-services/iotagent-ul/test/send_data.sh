# Send from device via http
curl "http://${IOTA_HTTP_EP}/iot/d?k=4jggokgpepnvsb2uv4s40d59ov&i=my_device_01" -d 't|37#l|1200' -H "Content-type: text/plain"

# Check from Orion
curl http://${ORION_EP}/v1/queryContext -H "Content-type: application/json" -H "Fiware-Service: openiot" -d '{
   "entities": [
       {
           "type": "", 
           "id": "my_entity_01", 
           "isPattern": "false"
       }
   ], 
   "attributes": []
}'


# New data from device
curl "http://${IOTA_HTTP_EP}/iot/d?k=4jggokgpepnvsb2uv4s40d59ov&i=my_device_01" -d 't|38#l|1200' -H "Content-type: text/plain"

# Check from Orion
curl http://${ORION_EP}/v1/queryContext -H "Content-type: application/json" -H "Fiware-Service: openiot" -d '{
   "entities": [
       {
           "type": "",
           "id": "my_entity_01",
           "isPattern": "false"
       }
   ],
   "attributes": []
}'