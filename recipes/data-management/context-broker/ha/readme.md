# Orion in HA

This recipe shows how to deploy an scalable
[Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md)
service backed with an scalable
[replica set](https://docs.mongodb.com/v3.2/replication/) of MongoDB instances.

All elements will be running in docker containers, defined in docker-compose
files. Actually, this recipe focuses on the deployment of the Orion frontend,
reusing the [mongodb replica recipe](../../../utils/mongo-replicaset/readme.md)
for its backend.

The final deployment is represented by the following picture:

<img src='http://g.gravizo.com/g?
  digraph G {
      rankdir=LR;
      	compound=true;
      	node [shape="record" style="filled"];
      	splines=line;
      	Client [fillcolor="aliceblue"];
      	subgraph cluster {
      		label="Docker Swarm Cluster";
      		"Load Balancer" [fillcolor="aliceblue"];
      		subgraph cluster_0 {
      			label="Orion Context Broker stack";
      			Orion1 [fillcolor="aliceblue"];
      			Orion2 [fillcolor="aliceblue"];
      			Orion3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="MongoDB Replica Set stack";
      			Mongo1 [fillcolor="aliceblue"];
      			Mongo2 [fillcolor="aliceblue"];
      			Mongo3 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> "Load Balancer" [label="1026",lhead=cluster_0];
      	"Load Balancer" -> {Orion1,Orion2,Orion3};
      	Orion1 -> Mongo1 [lhead=cluster_1];
      	Orion2 -> Mongo1 [lhead=cluster_1];
      	Orion3 -> Mongo1 [lhead=cluster_1];
      	Mongo1 -> {Mongo2, Mongo3} [dir="both"];
  }
'>

## Prerequisites

Please make sure you read the [welcome page](../../../index.md) and followed
the steps explained in the [installation guide](../../../installation.md).

## How to use

Firstly, you need to have a Docker Swarm (docker >= 1.13) already setup.
If you don't have one, checkout the [tools](../../../tools/readme.md) section
for a quick way to setup a local swarm.

```
$ miniswarm start 3
$ eval $(docker-machine env ms-manager0)
```

Orion needs a mongo database for its backend. If you have already deployed Mongo
within your cluster and would like to reuse that database, you can skip the next
step (deploying backend). You will just need to pay attention to the variables
you define for Orion to link to Mongo, namely, `MONGO_SERVICE_URI`. Make sure
you have the correct values in `settings.env` (or `settings.bat` in Windows).
The value of `MONGO_SERVICE_URI` should be a routable address for mongo.
If deployed within the swarm, the service name (with stack prefix)
would suffice. You can read more in the
[official docker docs](https://docs.docker.com/docker-cloud/apps/service-links/).
The default values should be fine for you if you used the
[Mongo ReplicaSet Recipe](../../../utils/mongo-replicaset/readme.md).

Now you can activate your settings and deploy Orion...

```
$ source settings.env  # In Windows, simply execute settings.bat instead.
$ docker stack deploy -c docker-compose.yml orion
```

At some point, your deployment should look like this...

```
$ docker service ls
ID            NAME                       MODE        REPLICAS  IMAGE
nrxbm6k0a2yn  mongo-rs_mongo             global      3/3       mongo:3.2
rgws8vumqye2  mongo-rs_mongo-controller  replicated  1/1       smartsdk/mongo-rs-controller-swarm:latest
zk7nu592vsde  orion_orion                replicated  3/3       fiware/orion:1.3.0
```

As shown above, if you see `3/3` in the replicas column it means the 3 replicas
are up and running.

## A walkthrough

You can check the distribution of the containers of a service (a.k.a tasks)
through the swarm running the following...

```
$ docker service ps orion_orion
ID            NAME           IMAGE               NODE         DESIRED STATE  CURRENT STATE               ERROR  PORTS
wwgt3q6nqqg3  orion_orion.1  fiware/orion:1.3.0  ms-worker0   Running        Running 9 minutes ago          
l1wavgqra8ry  orion_orion.2  fiware/orion:1.3.0  ms-worker1   Running        Running 9 minutes ago          
z20v0pnym8ky  orion_orion.3  fiware/orion:1.3.0  ms-manager0  Running        Running 25 minutes ago    
```

The good news is that, as you can see from the above output, by default docker
already took care of deploying all the replicas of the service
`context-broker_orion` to different hosts.

Of course, with the use of labels, constraints or deploying mode you have
the power to customize the distribution of tasks among swarm nodes. You can see
the [mongo replica recipe](../../../utils/mongo-replicaset) to understand
the deployment of the `mongo-replica_mongo` service.

Now, let's query Orion to check it's truly up and running.
The question now is... where is Orion actually running? We'll cover the network
internals later, but for now let's query the manager node...

```
$ sh ../query.sh $(docker-machine ip ms-manager0)
```

You will get something like...

```
{
  "orion" : {
  "version" : "1.3.0",
  "uptime" : "0 d, 0 h, 18 m, 13 s",
  "git_hash" : "cb6813f044607bc01895296223a27e4466ab0913",
  "compile_time" : "Fri Sep 2 08:19:12 UTC 2016",
  "compiled_by" : "root",
  "compiled_in" : "ba19f7d3be65"
}
}
[]
```

Thanks to the docker swarm internal routing mesh, you can actually perform
the previous query to any node of the swarm, it will be redirected to a node
where the request on port `1026` can be attended (i.e, any node running Orion).

Let's insert some data...

```
$ sh ../insert.sh $(docker-machine ip ms-worker1)
```

And check it's there...

```
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
```

Yes, you can query any of the three nodes.

Swarm's internal load balancer will be load-balancing in a round-robin approach
all the requests for an orion service among the orion tasks running
in the swarm.

## Rescaling Orion

Scaling up and down orion is a simple as runnnig something like...

```
$ docker service scale orion_orion=2
```

(this maps to the `replicas` argument in the docker-compose)

Consequently, one of the nodes (ms-worker1 in my case) is no longer running
Orion...

```
$ docker service ps orion_orion
ID            NAME                    IMAGE               NODE         DESIRED STATE  CURRENT STATE           ERROR  PORTS
2tibpye24o5q  orion_orion.2  fiware/orion:1.3.0  ms-manager0  Running        Running 11 minutes ago         
w9zmn8pp61ql  orion_orion.3  fiware/orion:1.3.0  ms-worker0   Running        Running 11 minutes ago
```

But still responds to the querying as mentioned above...

```
$ sh ../query.sh $(docker-machine ip ms-worker1)
{
  "orion" : {
  "version" : "1.3.0",
  "uptime" : "0 d, 0 h, 14 m, 30 s",
  "git_hash" : "cb6813f044607bc01895296223a27e4466ab0913",
  "compile_time" : "Fri Sep 2 08:19:12 UTC 2016",
  "compiled_by" : "root",
  "compiled_in" : "ba19f7d3be65"
}
}
[]
```

You can see the [mongo replica recipe](../../../utils/mongo-replicaset) to see
how to scale the mongodb backend. But basically, due to the fact that it's a
"global" service, you can scale it down like shown before. However, scaling it
up might require adding a new node to the swarm because there can be only one
instance per node.


## Dealing with failures

Docker is taking care of the reconciliation of the services in case a container
goes down. Let's show this by running the following (always on the manager
node):

```
$ docker ps
CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
abc5e37037f0        fiware/orion@sha256:734c034d078d22f4479e8d08f75b0486ad5a05bfb36b2a1f1ba90ecdba2040a9                 "/usr/bin/contextB..."   2 minutes ago       Up 2 minutes        1026/tcp            orion_orion.1.o9ebbardwvzn1gr11pmf61er8
1d79dca4ff28        smartsdk/mongo-rs-controller-swarm@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                        mongo-rs_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour    27017/tcp           mongo-rs_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz
```

Suppose orion container goes down...

```
$ docker rm -f abc5e37037f0
```

You will see it gone, but after a while it will automatically come back.

```
$ docker ps
CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
1d79dca4ff28        smartsdk/mongo-rs-controller-swarm@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                        mongo-rs_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour    27017/tcp           mongo-rs_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz

$ docker ps
CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS                  PORTS               NAMES
60ba3f431d9d        fiware/orion@sha256:734c034d078d22f4479e8d08f75b0486ad5a05bfb36b2a1f1ba90ecdba2040a9                 "/usr/bin/contextB..."   6 seconds ago       Up Less than a second   1026/tcp            orion_orion.1.uj1gghehb2s1gnoestup2ugs5
1d79dca4ff28        smartsdk/mongo-rs-controller-swarm@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                            mongo-rs_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour        27017/tcp           mongo-rs_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz
```

Even if a whole node goes down, the service will remain working because you had
both redundant orion instances and redundant db replicas.

```
$ docker-machine rm ms-worker0
```

You will still get replies to...

```
$ sh ../query.sh $(docker-machine ip ms-manager0)
$ sh ../query.sh $(docker-machine ip ms-worker1)
```

## Networks considerations

In this case, all containers are attached to the same overlay network (backend)
over which they communicate to each other. However, if you have a different
configuration and are running any of the containers behind a firewall, remember
to keep traffic open for TCP at ports 1026 (Orion's default) and 27017
(Mongo's default).

When containers (tasks) of a service are launched, they get assigned an IP
address in this overlay network. Other services of your application's
architecture should not be relying on these IPs because they may change
(for example, due to a dynamic rescheduling). The good think is that docker
creates a virtual ip for the service as a whole, so all traffic to this address
will be load-balanced to the tasks addresses.

Thanks to swarms docker internal DNS you can also use the name of the service
to connect to. If you look at the `docker-compose.yml` file of this recipe,
orion is started with the name of the mongo service as `dbhost` param
(regardless if it was a single mongo instance of a whole replica-set).

However, to access the container from outside of the overlay network (for
example from the host) you would need to access the ip of the container's
interface to the `docker_gwbridge`. It seem there's no easy way to get that
information from the outside (see
[this open issue](https://github.com/docker/libnetwork/issues/1082).
In the walkthrough, we queried orion through one of the swarm nodes because we
rely on docker ingress network routing the traffic all the way to one of the
containerized orion services.

## Open interesting issues

- [https://github.com/docker/swarm/issues/1106](https://github.com/docker/swarm/issues/1106)

- [https://github.com/docker/docker/issues/27082](https://github.com/docker/docker/issues/27082)

- [https://github.com/docker/docker/issues/29816](https://github.com/docker/docker/issues/29816)

- [https://github.com/docker/docker/issues/26696](https://github.com/docker/docker/issues/26696)

- [https://github.com/docker/docker/issues/23813](https://github.com/docker/docker/issues/23813)

More info about docker network internals can be read at:

- [Docker Reference Architecture](https://success.docker.com/KBase/Docker_Reference_Architecture%3A_Designing_Scalable%2C_Portable_Docker_Container_Networks)
