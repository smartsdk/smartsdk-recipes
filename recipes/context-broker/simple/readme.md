# Simple Scenario

##### Introduction
This simple recipe triggers an [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) instance backed with a [MongoDB](https://docs.mongodb.com) instance.

Both services will be running in docker containers, defined in the *simple/docker-compose.yml* file.

Data will be persisted, by default, in a local folder called data. However, this can changed by editing the value of *DATA_PATH* variable in the _.env_ file.

![Orion with Replica Set Overview](docs/compose.png "Simple compose overview")

##### How to use

Optionally, you can modify *.env* file (or even _docker-compose.yml_) according to your needs. Then simply run:

    $ docker-compose up -d

##### How to validate
Simply run the following command and it should return info about orion.

    $ curl localhost:1026/version
