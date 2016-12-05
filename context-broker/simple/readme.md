# Context Broker with persistence on MongoDB

This simple recipe triggers an [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) instance backed with a [MongoDB](https://docs.mongodb.com) instance.

All elements will be running in docker containers, defined in a docker-compose file.

## How to use

    $ git clone --recursive https://github.com/martel-innovate/smartsdk-recipes.git

    $ cd context-broker/simple

Optionally, modify _.env_ file (or even _docker-compose.py_) according to your needs.

    $ docker-compose up -d
