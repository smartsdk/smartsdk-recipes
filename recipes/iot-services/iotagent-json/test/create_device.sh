#!/bin/sh
curl -X POST -H "Fiware-Service: myHome" -H "Fiware-ServicePath: /environment" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{ 
    "devices": [ 
        { 
            "device_id": "sensor01", 
            "entity_name": "LivingRoomSensor", 
            "entity_type": "multiSensor", 
            "attributes": [ 
                  { "object_id": "t", "name": "Temperature", "type": "celsius" },
                  { "object_id": "l", "name": "Luminosity", "type": "lumens" }                  
            ]
        }
    ]
}

' "http://$IOTA_EP/iot/devices"
