#!/bin/sh
source frontend.env
# docker network create -d overlay frontend
env $(cat frontend.env | grep ^[A-Z] | xargs) docker stack deploy -c docker-compose.yml ${STACK_NAME}
