# Orion Context Broker in High Availability

The goal of this recipe is to allow developers instantiate N replicas of an [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) in a docker swarm cluster.

#### TODO: Turn this into a docker-compose file once the compose-swarm integration is ready.

To simplify, the following instructions will be using a simple docker swarm created with the scripts provided in the swarm folder. But of course, in practice, your swarm deployment will be different, depending on your chosen infrastructure.

    $ sh swarm/create-swarm.sh

Now, from the swarm-master node, create the networks:

    $ eval $(docker-machine env node-1)
    $ docker network create --driver overlay proxy
    $ docker network create --driver overlay hacb

Now it's time to create a swarm listener service, which will notify the proxy when new services
are created/removed so as to dynamically update the proxy configuration.

    $ docker service create --name swarm-listener \
        --network proxy \
        --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
        -e DF_NOTIF_CREATE_SERVICE_URL=http://proxy:8080/v1/docker-flow-proxy/reconfigure \
        -e DF_NOTIF_REMOVE_SERVICE_URL=http://proxy:8080/v1/docker-flow-proxy/remove \
        --constraint 'node.role==manager' \
        vfarcic/docker-flow-swarm-listener

Note that services might take some time until fully deployed. So, please wait until all the requested replicas are ready before creating new services. This can be done running:

    $ docker service ls

Now create the proxy service.

    $ docker service create --name proxy \
        -p 80:80 \
        -p 443:443 \
        -p 1026:1026 \
        --network proxy \
        -e MODE=swarm \
        -e LISTENER_ADDRESS=swarm-listener \
        vfarcic/docker-flow-proxy

Then the database (be patient until it's ready).

    $ docker service create --name mongo --network hacb mongo:3.2 --nojournal

And finally Orion, linking to mongo as usual.

    $ docker service create --name orion \
    --network hacb \
    --network proxy \
    --label com.df.notify=true \
    --label com.df.distribute=true \
    --label com.df.servicePath=/version \
    --label com.df.port=1026 \
    fiware/orion -dbhost mongo

Now let's query Orion from the proxy to check it's up and running:

    $ curl -i $(docker-machine ip node-1):1026/version
