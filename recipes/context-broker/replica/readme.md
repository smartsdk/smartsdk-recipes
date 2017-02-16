# Orion in HA

This recipe shows how to deploy an scalable [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) service backed with an scalable [replica set](https://docs.mongodb.com/v3.2/replication/) of MongoDB instances.

All elements will be running in docker containers, defined in docker-compose files. Actually, this recipe reuses the [mongodb replica recipe](../../mongodb/replica/readme.md).

<img src='http://g.gravizo.com/g?
  digraph G {
      rankdir=LR;
      	compound=true;
      	node [shape="record" style="filled"];
      	splines=line;
      	Client [fillcolor="aliceblue"];
      	subgraph cluster {
      		label="Docker Swarm";
      		Internal_LB;
      		subgraph cluster_0 {
      			label="Orion Context Broker cluster";
      			Orion1 [fillcolor="aliceblue"];
      			Orion2 [fillcolor="aliceblue"];
      			Orion3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="MongoDB Replica Set";
      			Mongo1 [fillcolor="aliceblue"];
      			Mongo2 [fillcolor="aliceblue"];
      			Mongo3 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> Internal_LB [label="1026",lhead=cluster_0];
      	Internal_LB -> {Orion1,Orion2,Orion3};
      	Orion1 -> Mongo1 [lhead=cluster_1];
      	Orion2 -> Mongo1 [lhead=cluster_1];
      	Orion3 -> Mongo1 [lhead=cluster_1];
      	Mongo1 -> {Mongo2, Mongo3} [dir="both"];
  }
'>

The recipe's configuration, as of now, is more suitable for a __development environment__. It has some default values which you might be able to customize with ease.


##### How to use

Firstly, you need to have a Docker Swarm already setup. If you don't have one, checkout the [tools](../../tools/readme.md) section for a quick way to setup a local swarm.

    $ miniswarm start 3
    $ eval $(docker-machine env ms-manager0)

Then, we need to deploy the [mongodb replica](../../mongodb/replica/readme.md) stack.

    $ docker stack deploy -c ../../mongodb/replica/docker-compose.yml mongo-replica

A quick check would be...

    $ docker service ls
    ID            NAME                            MODE        REPLICAS  IMAGE
    f081tcqr7rce  mongo-replica_mongo             global      3/3       mongo:latest
    wq7quugr9b12  mongo-replica_mongo-controller  replicated  1/1       taliaga/mongo-replica-ctrl:latest

Now, we deploy the orion stack

    $ docker stack deploy -c docker-compose.yml orion-stack

Allow some time until things get connected before querying for content. At this point we have 3 containers running Orion in 3 different nodes and 3 containers running mongo in a replicaset, also scattered in different nodes.

    $ docker service ls

    $ docker service ls
    ID            NAME                            MODE        REPLICAS  IMAGE
    0ykzt0fjswz2  orion-stack_orion               replicated  3/3       fiware/orion:1.3.0
    f081tcqr7rce  mongo-replica_mongo             global      3/3       mongo:latest
    wq7quugr9b12  mongo-replica_mongo-controller  replicated  1/1       taliaga/mongo-replica-ctrl:latest

And we check the status of orion...

    $ sh ../query.sh $(docker-machine ip ms-manager0)
    {
      "orion" : {
      "version" : "1.3.0",
      "uptime" : "0 d, 0 h, 2 m, 33 s",
      "git_hash" : "cb6813f044607bc01895296223a27e4466ab0913",
      "compile_time" : "Fri Sep 2 08:19:12 UTC 2016",
      "compiled_by" : "root",
      "compiled_in" : "ba19f7d3be65"
    }
    }
    []

__IMPORANT__: If you want to change the names of the stacks, do it keeping consistency when referenced among the recipes.


##### A walkthrough

Let's insert some data...

    $ sh ../insert.sh $(docker-machine ip ms-worker1)

And check it's there...

    $ sh ../query.sh $(docker-machine ip ms-worker0)
    ...
    [
        {
            "id": "Room1",
            "pressure": {
                "metadata": {},
                "type": "Integer",
                "value": 720
            },
            "temperature": {
                "metadata": {},
                "type": "Float",
                "value": 23
            },
            "type": "Room"
        }
    ]

Yes, you can query any of the nodes. As explained in the [scalable recipe](../scalable/readme.md), the request will be routed to a node running the orion service. In fact, multiple requests will be load-balanced in a round-robin fashion by docker itself to those services.

Docker is taking care of the reconciliation of the services in case a container goes down. Let's show this by running the following (always on the manager node):

    $ docker ps
    CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
    abc5e37037f0        fiware/orion@sha256:734c034d078d22f4479e8d08f75b0486ad5a05bfb36b2a1f1ba90ecdba2040a9                 "/usr/bin/contextB..."   2 minutes ago       Up 2 minutes        1026/tcp            orion-stack_orion.1.o9ebbardwvzn1gr11pmf61er8
    1d79dca4ff28        taliaga/mongo-replica-ctrl@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                        mongo-replica_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
    8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour    27017/tcp           mongo-replica_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz

Suppose orion container goes down...

    $ docker rm -f abc5e37037f0

You will see it gone, but after a while it will automatically come back.

    $ docker ps
    CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
    1d79dca4ff28        taliaga/mongo-replica-ctrl@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                        mongo-replica_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
    8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour    27017/tcp           mongo-replica_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz

    $ docker ps
    CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS                  PORTS               NAMES
    60ba3f431d9d        fiware/orion@sha256:734c034d078d22f4479e8d08f75b0486ad5a05bfb36b2a1f1ba90ecdba2040a9                 "/usr/bin/contextB..."   6 seconds ago       Up Less than a second   1026/tcp            orion-stack_orion.1.uj1gghehb2s1gnoestup2ugs5
    1d79dca4ff28        taliaga/mongo-replica-ctrl@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                            mongo-replica_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
    8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour        27017/tcp           mongo-replica_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz

Even if a whole node goes down, the service will remain working because we had both redundant orion instances and redundant db replicas.

    $ docker-machine rm ms-worker0

You will still get replies to...

        $ sh ../query.sh $(docker-machine ip ms-manager0)
        $ sh ../query.sh $(docker-machine ip ms-worker1)


##### Networks considerations

In this case, all containers are attached to the same overlay network (mongo-replica_replica) over which they communicate to each other. However, if you have a different configuration and are running any of the containers behind a firewall, remember to keep traffic open for TCP at ports 1026 (Orion's default) and 27017 (Mongo's default).
