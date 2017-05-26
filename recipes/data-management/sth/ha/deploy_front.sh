#!/bin/bash
set -o allexport
. ./frontend.env
set +o allexport
# docker network create -d overlay frontend
docker stack deploy -c docker-compose.yml ${STACK_NAME}
