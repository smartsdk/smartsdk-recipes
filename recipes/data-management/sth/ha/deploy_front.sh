#!/bin/bash
set -o allexport
. ./frontend.env
set +o allexport
docker stack deploy -c docker-compose.yml ${STACK_NAME}
