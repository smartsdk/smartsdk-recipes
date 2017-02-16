# Scalable Orion

The goal of this recipe is to show how to deploy [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md) as an scalable service in a docker swarm cluster.

This recipe works with a single instance of the backend db. If you also want to scale the backend, refer to the [ha recipe](../ha/readme.md).

<img src='http://g.gravizo.com/g?
digraph Cluster {
    rankdir=LR;
	compound=true;
	node [shape="record" style="filled"];
	splines=line;
	Client [fillcolor="aliceblue"];
	subgraph cluster {
		label="Docker Swarm";
        style=filled;
		color=aliceblue;
        subgraph cluster_1 {
            label="ms-worker0";
            color=white;
            Orion2 [fillcolor="aliceblue"];
        }
        subgraph cluster_0 {
            label="ms-manager0";
            color=white;
            Orion1 [fillcolor="aliceblue"];
            Mongo1 [fillcolor="aliceblue"];
        }
        subgraph cluster_2 {
            label="ms-worker1";
            color=white;
            Orion3 [fillcolor="aliceblue"];
        }
	}
    Orion2 -> Mongo1 [dir="both"];
    Orion3 -> Mongo1 [dir="both"];
	Orion1 -> Mongo1 [dir="both"];
    Client -> Orion1 [label="1026",lhead=cluster_0];
    Orion1 -> Orion3 [dir="both"];
    Orion1 -> Orion2 [dir="both"];
}
'>

##### How to run it

First you need to have a Docker Swarm already setup. If you don't have one, checkout the [tools](../../tools/readme.md) section for a quick way to setup a local swarm.

    $ miniswarm start 3
    $ eval $(docker-machine env ms-manager0)

Then you can _optionally_ adjust _docker-compose.yml_ file according to your needs. If you do so, checkout the [docker-compose documentation](https://docs.docker.com/compose/compose-file) to avoid conflicting options (e.g, giving container name to orion and then trying to scale it).

Finally, run:

    $ docker stack deploy -c docker-compose.yml context-broker

##### A walkthrough

Note that services might take some time until fully deployed. So, please wait until all the requested replicas are ready. This can be checked running:

    $ docker service ls

    ID            NAME                  MODE        REPLICAS  IMAGE
    ugr3822etoce  context-broker_orion  replicated  3/3       fiware/orion:1.3.0
    wgd37l6da2lx  context-broker_mongo  replicated  1/1       mongo:3.2

As shown above, when you see _3/3_ in the replicas column it means the 3 replicas are up and running.

You can check the distribution of the containers of a service (context-broker_orion) through the swarm running:

    $ docker service ps context-broker_orion
    ID            NAME                    IMAGE               NODE         DESIRED STATE  CURRENT STATE               ERROR  PORTS
    vs1ew5yszca6  context-broker_orion.1  fiware/orion:1.3.0  ms-worker1   Running        Running about a minute ago         
    2tibpye24o5q  context-broker_orion.2  fiware/orion:1.3.0  ms-manager0  Running        Running about a minute ago         
    w9zmn8pp61ql  context-broker_orion.3  fiware/orion:1.3.0  ms-worker0   Running        Running about a minute ago  

The good news is that, as you can see from the above output, by default docker already took care of deploying the service to different hosts. However, with the use of labels, constraints or deploying mode you have the power to customize the distribution of tasks among swarm nodes.

Now let's query Orion to check it's up and running. The question now is... where is Orion actually running? As a matter of facts, there are actually 3 containers running instances of Orion. We'll cover the network internals later, but for now let's query the manager node...

    $ sh ../query.sh $(docker-machine ip ms-manager0)

You will get something like...

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

Thanks to the docker swarm internal routing mesh, you can actually perform the previous query to any node of the swarm, it will be redirected to a node where the request on port 1026 can be attended (i.e, any node running Orion).

##### Rescaling Orion

Scaling up and down is a simple as runnnig something like...

    $ docker service scale context-broker_orion=2

(maps to the _"replicas"_ argument in the docker-compose)

One of the nodes is no longer running Orion...

    $ docker service ps context-broker_orion
    ID            NAME                    IMAGE               NODE         DESIRED STATE  CURRENT STATE           ERROR  PORTS
    2tibpye24o5q  context-broker_orion.2  fiware/orion:1.3.0  ms-manager0  Running        Running 11 minutes ago         
    w9zmn8pp61ql  context-broker_orion.3  fiware/orion:1.3.0  ms-worker0   Running        Running 11 minutes ago

But still responds to the querying as mentioned above...

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
