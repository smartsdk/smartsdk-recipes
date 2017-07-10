#!/bin/bash
. ./frontend.env
docker network create --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1500} -d overlay frontend
env $(cat frontend.env | grep ^[A-Z] | xargs) docker stack deploy -c docker-compose.yml ${STACK_NAME}
