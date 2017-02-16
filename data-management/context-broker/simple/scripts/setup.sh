#!/bin/bash
# You can edit here the options passed to contextBroker.
echo "Running setup.sh..."
/usr/bin/contextBroker -fg -multiservice -dbhost mongo
