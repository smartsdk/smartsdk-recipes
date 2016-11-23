#!/bin/bash
# Reset
docker stop $DB_NAME $ORION_NAME
docker rm $DB_NAME $ORION_NAME
