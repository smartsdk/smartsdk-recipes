#!/bin/bash
set -o allexport
. ./backend.env
set +o allexport
curl https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/docker-compose.yml -o docker-compose-mongo.yml
curl -O https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/mongo-healthcheck
docker stack deploy -c docker-compose-mongo.yml ${STACK_NAME}
