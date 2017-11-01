#!/bin/sh

curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Fiware-Service: myHome" -H "Fiware-ServicePath: /environment" -H "Cache-Control: no-cache" -d '{"type" : "configuration", "value" : "300"}' "http://${ORION_EP}/v1/contextEntities/LivingRoomSensor/attributes/sleepTime"