#!/bin/sh
docker network create -d overlay --attachable --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1400} backend
docker network create -d overlay --attachable --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1400} frontend
