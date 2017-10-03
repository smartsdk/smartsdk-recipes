#!/bin/bash
# Simple script to insert something into Orion Context Broker
if [[ "$1" != "" ]]; then
    host=$1
else
    host="0.0.0.0"
fi

if [[ "$2" != "" ]]; then
    port=$2
else
    port=8668
fi

curl -X POST $host:$port/notify -H 'content-type: application/json' -d @- <<EOF
{
	"subscriptionId": "5947d174793fe6f7eb5e3961",
	"data": [
		{
			"id": "Room1",
			"type": "Room",
			"temperature": {
				"type": "Number",
				"value": 27.6,
				"metadata": {
					"dateModified": {
						"type": "DateTime",
						"value": "2017-06-19T11:46:45.00Z"
					}
				}
			}
		}
	]
}
EOF
