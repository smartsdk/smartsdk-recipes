# MongoDB Replica Set

This recipe aims to deploy and control a [replica set](https://docs.mongodb.com/manual/replication/) of MongoDB instances in a Docker Swarm.

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

**IMPORTANT:** This recipe is not yet ready for production environments. See _further improvements_ section for more details.


## How to use

Firstly, you need to have a Docker Swarm (docker >= 1.13) already setup. If you don't have one, checkout the [tools](../../../tools/readme.md) section for a quick way to setup a local swarm.

    miniswarm start 3
    eval $(docker-machine env ms-manager0)

Then, simply run...

    sh deploy.sh

Allow some time while images are pulled in the nodes and services are deployed. After a couple of minutes, you can check if all services are up, as usual, running...

    $ docker service ls
    ID            NAME                            MODE        REPLICAS  IMAGE
    fjxof1n5ce58  mongo-replica_mongo             global      3/3       mongo:latest
    yzsur7rb4mg1  mongo-replica_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest


## A Walkthrough

As shown before, the recipe consists of basically two services, namely, one for mongo instances and one for controlling the replica-set.

The mongo service is deployed in "global" mode, meaning that docker will run one instance of mongod per swarm node in the cluster.

At the swarm's master node, a python-based controller script will be deployed to configure and maintain the mongodb replica-set.

Let's now check that the controller worked fine inspecting the logs of the mongo-replica_mongo-controller service. This can be done with either...

    $ docker service logs mongo-replica_mongo-controller

or running the following...

    $  docker logs $(docker ps -f "name=mongo-replica_mongo-controller" -q)
    INFO:__main__:Waiting some time before starting
    INFO:__main__:Initial config: {'version': 1, '_id': 'rs', 'members': [{'_id': 0, 'host': '10.0.0.5:27017'}, {'_id': 1, 'host': '10.0.0.3:27017'}, {'_id': 2, 'host': '10.0.0.4:27017'}]}
    INFO:__main__:replSetInitiate: {'ok': 1.0}

As you can see, the replica-set was configured with 3 replicas represented by containers running in the same overlay network. You can also run a mongo command in any of the mongo containers and execute *rs.status()* to see the same results.

    $ docker exec -ti d56d17c40f8f mongo
    rs:SECONDARY> rs.status()


## Rescaling the replica-set

Let's add a new node to the swarm to see how docker deploys a new task of the mongo service and the controller automatically adds it to the replica-set.

    # First get the token to join the swarm
    $ docker swarm join-token worker

    # Create the new node
    $ docker-machine create -d virtualbox ms-worker2
    $ docker-machine ssh ms-worker2

    docker@ms-worker2:~$ docker swarm join \
    --token INSERT_TOKEN_HERE \
    192.168.99.100:2377

    docker@ms-worker2:~$ exit

Back to the host, some minutes later...

    $ docker service ls
    ID            NAME                            MODE        REPLICAS  IMAGE
    fjxof1n5ce58  mongo-replica_mongo             global      4/4       mongo:latest
    yzsur7rb4mg1  mongo-replica_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest

    $ docker logs $(docker ps -f "name=mongo-replica_mongo-controller" -q)
    ...
    INFO:__main__:To add: {'10.0.0.8'}
    INFO:__main__:New config: {'version': 2, '_id': 'rs', 'members': [{'_id': 0, 'host': '10.0.0.5:27017'}, {'_id': 1, 'host': '10.0.0.3:27017'}, {'_id': 2, 'host': '10.0.0.4:27017'}, {'_id': 3, 'host': '10.0.0.8:27017'}]}
    INFO:__main__:replSetReconfig: {'ok': 1.0}

If a node goes down, the replica-set will be automatically reconfigured at the application level by mongo. Docker, on the other hand, will not reschedule the replica because it's expected to run one only one per node.

_NOTE_: If you don't want to have a replica in every node of the swarm, the solution for now is using a combination of constraints and node tags. You can read more about this in [this Github issue](https://github.com/docker/docker/issues/26259).

For further details, refer to the *[docker-compose.yml](https://github.com/martel-innovate/smartsdk-recipes/blob/master/recipes/utils/mongodb/replica/docker-compose.yml)* file or *[replica_ctrl.py](https://github.com/martel-innovate/smartsdk-recipes/blob/master/recipes/utils/mongodb/replica/scripts/replica_ctrl.py)*.


## Challenges and Further improvements

The main challenge for this script was to know at runtime where each mongod instance was running so as to configure the replica-set properly. The idea of the new orchestration features in swarm is that you really shouldn't care where they run as long as swarm keeps them up and running. But mongo needs to know that in order to configure the replica set.

So the first approach is to find out this information from the docker api. Also, since the recipe is expected to be self-contained and work without dependencies on things running outside the swarm, we need to get this information from a container running in the swarm. My understanding is that such an introspective api to safely retrieve this kind of information is yet to come (e.g [this issue](https://github.com/docker/docker/issues/8427) and related ones such as [this one](https://github.com/docker/docker/issues/1143#issuecomment-233152700)). So for now this is depending on access to the host's docker socket **(terribly insecure workaround)**. A different approach to explore would be passing to the script at runtime the list of IPs. IPs of the containers if possible, or if not, IPs of the nodes where the services are deployed and use different ports in each replica member so as to avoid clashes in the docker ingress network. Or, something considering a custom IPM via plugins.

Further things to keep in mind:

- The script has some improvement suggestions marked with TODO comments.
- At the moment this recipe does not include a data persistence solution.
- Consider using authentication in the replica-set.
