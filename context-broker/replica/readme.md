# Orion With Replica Set

This recipe aims to allow developers to instantiate an [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) instance backed with a [replica set](https://docs.mongodb.com/v3.2/replication/) of MongoDB instances.

All elements will be running in docker containers, defined in a docker-compose file.

![Orion with Replica Set Overview](docs/replica_overview.png "Orion with replica set overview")

The recipe's configuration as of now is more suitable for a __development environment__. It has some default values which you might be able to edit with ease.

The replicas will all be launched in the local environment, but nothing prohibits deploying replicas in different hosts, in fact, that would be more likely in a production deployment scenario.

If you are planning to use it in a __production environment__, further considerations need to be taken into account as show in the corresponding section.


## Using locally

#### How to use

    $ git clone --recursive https://github.com/martel-innovate/smartsdk-recipes.git

    $ cd context-broker/replica

Optionally, modify _.env_ file (or even _docker-compose.py_) according to your needs.

    $ docker-compose up -d

Allow some time until things get connected before querying for content.

#### How it works

The way this work is pretty straightforward. To begin with, there are three mongo containers
that will be triggered (mongo1, mongo2, mongo3).

A fourth container (mongosetup) will wait for _mongo1_ to be ready and then execute the *setup_replica.sh* script to configure the replica set with the 3 mongo instances.

The fifth and last container will host Orion, who will be linked to the _mongo1_ container as its backend once its ready. It will execute *setup_orion.sh* to start Orion in the replicaset mode with enough timeout for the actual replica to be ready.

![Orion with Replica Set Details](docs/replica_details.png "Orion with replica set details")

You can experiment different configurations, including timeouts, by editing the file _.env_ before calling docker-compose.

#### Troubleshooting
- If Orion fails to connect to the database try to restart it.
        $ docker restart orion

## Using distributed

To be completed after deciding deployment options...

## Important considerations

 - All nodes must be in the same network, in other words, reachable among them.
 - If you are running behind a firewall, make sure to keep traffic open for TCP at ports 1026 (Orion's default) and 27017 (Mongo's default)
