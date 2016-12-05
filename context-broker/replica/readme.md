# Orion With Replica Set

This recipe aims to allow developers to instantiate an Orion Context Broker instance backed with a [replica set](https://docs.mongodb.com/v3.2/replication/) of MongoDB instances. All elements will be running in docker containers, defined in a docker-compose file.

[ADD PATTERN IMAGE HERE]()

The recipe's configuration as of now is more suitable for a __development environment__. It has some default values which you might be able to edit with ease.

The replicas will all be launched in the local environment, but nothing prohibits deploying replicas in different hosts, in fact, that would be more likely in a production deployment scenario.

If you are planning to use it in a __production environment__, further considerations need to be taken into account as show in the corresponding section.


## Using locally

#### How to use

    $ git clone --recursive https://github.com/?

    $ cd context-broker/replica

    $ docker-compose up -d

#### How it works

#### Troubleshooting
- If Orion fails to conect to the database try a restart
        $ docker restart orion

## Using distributed

#### How to use
- define your cluster?

#### How it works

## Important considerations

 - All nodes must be in the same network, in other words, reachable among them.
 - If you are running behind a firewall, make sure to keep traffic open for TCP at ports 1026 (orion default) and 27017 (mongo default)
