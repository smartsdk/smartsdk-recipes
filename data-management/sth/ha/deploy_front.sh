#!/bin/bash
set -o allexport
. ./backend.env
. ./frontend.env
set +o allexport
docker stack deploy -c docker-compose.yml ${STACK_NAME}
