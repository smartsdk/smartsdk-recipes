#!/bin/bash
set -o allexport
. ./frontend.env
set +o allexport
# docker network create --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1500} -d overlay frontend
docker stack deploy -c docker-compose.yml ${STACK_NAME}
