#!/bin/bash
MONGO_VERSION=3.2
ORION_NAME=orion1
DB_NAME=mongotest  # name of db container
DATAPATH=$PWD/data  # path to mounted folder for data persistence

# mongoDB: no persistence!
#docker run --name ${DB_NAME} -d mongo:${MONGO_VERSION}
# mongoDB: mounted data partition
docker run --name ${DB_NAME} -v ${DATAPATH}:/data/db -d mongo:${MONGO_VERSION}

docker run -d --name $ORION_NAME --link ${DB_NAME}:${DB_NAME} -p 1026:1026 fiware/orion -dbhost ${DB_NAME}
