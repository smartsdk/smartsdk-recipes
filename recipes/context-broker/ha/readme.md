# Orion in HA

The goal of this recipe is to allow developers instantiate N replicas of an [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) in a docker swarm cluster.

##### How to run it

First you need to have a Docker Swarm already setup. Checkout the [tools](../../tools/readme.md) section for a quick alternative for local tests.

Then you can optionally adjust _docker-compose.yml_ file according to your needs. If you do so, checkout the [docker-compose documentation](https://docs.docker.com/compose/compose-file) to avoid conflicting options (e.g, giving container name to orion and then trying to scale it).

Finally, run:

    $ docker stack deploy --compose-file=docker-compose.yml context-broker

##### How to validate it

Note that services might take some time until fully deployed. So, please wait until all the requested replicas are ready before creating new services. This can be done running:

    $ docker service ls

You can check the distribution of your containers among the swarm node running:

    $ docker service ps context-broker_orion

Now let's query Orion to check it's up and running:

    $ curl -i $(docker-machine ip ms-manager0):1026/version

Thanks to the docker swarm internal meshing you can actually perform the previous query to any node of the swarm, it will be redirected to a node where the request on port 1026 can be attended (any node running Orion).
