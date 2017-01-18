#!/bin/bash
# Simple script to query Orion Context Broker
curl localhost:1026/version
curl localhost:1026/v2/entities -s -S --header 'Accept: application/json' | python -mjson.tool
