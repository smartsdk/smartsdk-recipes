#!/bin/bash

# echo "Waiting for startup.."
# until curl http://${MONGODB1}:28017/serverStatus\?repl=\1\&text=\1 2>&1 | grep uptime | head -1; do
#   printf '.'
#   sleep 1
# done
#
sleep 10
echo "Now is the time to start orion..."
/usr/bin/contextBroker -fg -multiservice -dbhost mongo1 -rplSet rs -dbTimeout 10000
echo "Finished starting orion...?"
