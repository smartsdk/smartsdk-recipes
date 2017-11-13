#!/bin/sh

curl -H "Fiware-Service: myHome" -H "Fiware-ServicePath: /environment" ${IOTA_EP}/iot/devices
