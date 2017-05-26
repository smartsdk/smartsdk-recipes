#!/bin/sh
set -o allexport
. ./backend.env
set +o allexport
docker network create -d overlay backend
docker stack deploy -c docker-compose.yml ${STACK_NAME}
