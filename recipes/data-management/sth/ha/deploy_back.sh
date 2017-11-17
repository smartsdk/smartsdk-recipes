#!/bin/bash
set -o allexport
. ./backend.env
set +o allexport
curl -O https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/docker-compose.yml -o mongo-docker-compose.yml
curl -O https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/mongo-healthcheck
docker stack deploy -c mongo-docker-compose.yml ${STACK_NAME}
