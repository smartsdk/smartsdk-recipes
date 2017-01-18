#!/bin/bash
sleep 10

echo "Now is the time to start orion..."
/usr/bin/contextBroker -fg -multiservice -dbhost mongo1 -rplSet rs -dbTimeout 10000
echo "Finished starting orion..."
