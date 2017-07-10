#!/bin/bash
set -o allexport
. ./backend.env
set +o allexport
# docker network create --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1500} -d overlay backend
docker stack deploy -c ../../../utils/mongodb/replica/docker-compose.yml ${STACK_NAME}
