#!/bin/sh
source backend.env
# docker network create -d overlay backend
env $(cat backend.env | grep ^[A-Z] | xargs) docker stack deploy -c ../../../utils/mongodb/replica/docker-compose.yml ${STACK_NAME}
