# MongoDB Replica Set

This recipe aims to deploy and control a
[replica set](https://docs.mongodb.com/manual/replication/) of MongoDB
instances in a Docker Swarm.

<img src='http://g.gravizo.com/g?
digraph Cluster {
    rankdir=LR;
       compound=true;
       node [shape="record" style="filled"];
       splines=line;
       subgraph cluster {
               label="Docker Swarm";
        style=filled;
               color=aliceblue;
        subgraph cluster_1 {
            label="ms-worker0";
            color=white;
            Mongo2 [fillcolor="aliceblue"];
        }
        subgraph cluster_0 {
            label="ms-manager0";
            color=white;
            Controller [fillcolor="aliceblue"];
            Mongo1 [fillcolor="aliceblue"];
        }
        subgraph cluster_2 {
            label="ms-worker1";
            color=white;
            Mongo3 [fillcolor="aliceblue"];
        }
       }
    Mongo1 -> Mongo2 [dir="both"];
    Mongo2 -> Mongo3 [dir="both"];
    Mongo3 -> Mongo1 [dir="both"];
    Controller -> Mongo1;
}
'>

## Requirements

Please make sure you read the [welcome page](../../index.md) and followed the
steps explained in the [installation guide](../../installation.md).

## How to use

Firstly, you need to have a Docker Swarm (docker >= 1.13) already setup.
If you don't have one, checkout the [tools](../../tools/readme.md) section for
a quick way to setup a local swarm.

```
$ miniswarm start 3
$ eval $(docker-machine env ms-manager0)
```

Then, simply run from this same folder...

```
$ source settings.env  # In Windows, simply execute settings.bat instead.
$ docker stack deploy -c docker-compose.yml mongo-rs
```

Allow some time while images are pulled in the nodes and services are deployed.
After a couple of minutes, you can check if all services are up, as usual,
running...

```
$ docker service ls
ID            NAME                            MODE        REPLICAS  IMAGE
fjxof1n5ce58  mongo-rs_mongo             global      3/3       mongo:latest
yzsur7rb4mg1  mongo-rs_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest
```

## A Walkthrough

As shown before, the recipe consists of basically two services, namely, one for
mongo instances and one for controlling the replica-set.

The mongo service is deployed in "global" mode, meaning that docker will run one
instance of mongod per swarm node in the cluster.

At the swarm's master node, a python-based controller script will be deployed to
configure and maintain the mongodb replica-set.

Let's now check that the controller worked fine inspecting the logs of the
`mongo-rs_controller` service. This can be done with either...

```
$ docker service logs mongo-rs_controller
```

or running the following...

```
$  docker logs $(docker ps -f "name=mongo-rs_controller" -q)
INFO:__main__:Waiting some time before starting
INFO:__main__:Initial config: {'version': 1, '_id': 'rs', 'members': [{'_id': 0, 'host': '10.0.0.5:27017'}, {'_id': 1, 'host': '10.0.0.3:27017'}, {'_id': 2, 'host': '10.0.0.4:27017'}]}
INFO:__main__:replSetInitiate: {'ok': 1.0}
```

As you can see, the replica-set was configured with 3 replicas represented by
containers running in the same overlay network. You can also run a mongo command
in any of the mongo containers and execute `rs.status()` to see the same
results.

```
$ docker exec -ti d56d17c40f8f mongo rs:SECONDARY> rs.status()
```

## Rescaling the replica-set

Let's add a new node to the swarm to see how docker deploys a new task of the
mongo service and the controller automatically adds it to the replica-set.

```
# First get the token to join the swarm
$ docker swarm join-token worker

# Create the new node
$ docker-machine create -d virtualbox ms-worker2
$ docker-machine ssh ms-worker2

docker@ms-worker2:~$ docker swarm join \
--token INSERT_TOKEN_HERE \
192.168.99.100:2377

docker@ms-worker2:~$ exit
```

Back to the host, some minutes later...

```
$ docker service ls
ID            NAME                            MODE        REPLICAS  IMAGE
fjxof1n5ce58  mongo-rs_mongo             global      4/4       mongo:latest
yzsur7rb4mg1  mongo_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest

$ docker logs $(docker ps -f "name=mongo_mongo-controller" -q)
...
INFO:__main__:To add: {'10.0.0.8'}
INFO:__main__:New config: {'version': 2, '_id': 'rs', 'members': [{'_id': 0, 'host': '10.0.0.5:27017'}, {'_id': 1, 'host': '10.0.0.3:27017'}, {'_id': 2, 'host': '10.0.0.4:27017'}, {'_id': 3, 'host': '10.0.0.8:27017'}]}
INFO:__main__:replSetReconfig: {'ok': 1.0}
```

If a node goes down, the replica-set will be automatically reconfigured at
the application level by mongo. Docker, on the other hand, will not reschedule
the replica because it's expected to run one only one per node.

_NOTE_: If you don't want to have a replica in every node of the swarm,
the solution for now is using a combination of constraints and node tags.
You can read more about this in
[this Github issue](https://github.com/docker/docker/issues/26259).

For further details, refer to the [mongo-rs-controller-swarm](https://github.com/smartsdk/mongo-rs-controller-swarm)
repository, in particular the [docker-compose.yml](https://github.com/smartsdk/mongo-rs-controller-swarm/blob/master/docker-compose.yml)
file or the
[replica_ctrl.py](https://github.com/smartsdk/mongo-rs-controller-swarm/blob/master/src/replica_ctrl.py)
controller script.
