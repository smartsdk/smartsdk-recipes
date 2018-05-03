#!/bin/bash

# This command could be executed as a pre-commit hook.
# We will keep even the generated files commited so that the user experience is
# simplified. No problem with duplicated files as long as they're autogenenated.

# Fetch external files
## Utils
curl -o ../utils/mongo-replicaset/docker-compose.yml -O https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/docker-compose.yml
curl -o ../utils/mongo-replicaset/mongo-healthcheck -O https://raw.githubusercontent.com/smartsdk/mongo-rs-controller-swarm/master/mongo-healthcheck

# Generate Mastermind Files
# ...

# Generate Portainer Templates
# ...
