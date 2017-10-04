#!/bin/sh
set -o allexport
. ./backend.env
set +o allexport
docker network create --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1500} -d overlay backend
curl -O https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/docker-compose.yml
docker stack deploy -c docker-compose.yml ${STACK_NAME}
