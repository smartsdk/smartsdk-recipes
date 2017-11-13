#!/bin/bash
. ./frontend.env
env $(cat frontend.env | grep ^[A-Z] | xargs) docker stack deploy -c docker-compose.yml ${STACK_NAME}
