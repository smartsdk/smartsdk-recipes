# Orion with DB in replica-set

This recipe offers an [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) instance backed with a [replica set](https://docs.mongodb.com/v3.2/replication/) of MongoDB instances.

All elements will be running in docker containers, defined in docker-compose files.

It reuses the [mongodb replica recipe](../../mongodb/replica/readme.md).

![Orion with Replica Set Overview](docs/replica_overview.png "Orion with replica set overview")

The recipe's configuration as of now is more suitable for a __development environment__. It has some default values which you might be able to edit with ease.

##### How to use

First run the [mongodb replica recipe](../../mongodb/replica/readme.md). Then...

    # Optionally, modify _docker-compose.yml_ according to your needs.

    $ docker-compose up -d

Allow some time until things get connected before querying for content.

##### How it works

For the MongoDB replicaset part refer to [How it works](../../mongodb/replica/readme.md) of the MongoDB replicaset recipe.

Then, with enough timeout for the actual replica to be ready, a container is launched using the script *setup_orion.sh* as entrypoint to start Orion in the _replicaset_ mode.

![Orion with Replica Set Details](docs/replica_details.png "Orion with replica set details")

##### Important considerations

 - All containers must be in the same network, in other words, reachable among them.
 - If you are running containers behind a firewall, make sure to keep traffic open for TCP at ports 1026 (Orion's default) and 27017 (Mongo's default)

##### Troubleshooting
 - If Orion fails to connect to the database, try to restart it.

         $ docker restart orion
