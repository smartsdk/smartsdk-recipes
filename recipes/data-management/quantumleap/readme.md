# QuantumLeap


## Introduction
Here you can find recipes aimed at different usages of QuantumLeap. We assume you are already familiar with it, otherwise refer to the [official documentation](https://smartsdk.github.io/ngsi-timeseries-api/).

Instructions on how to prepare your environment to test these recipes are given in the [installation section](../../installation.md).


## HA Deployment overview

<img src='http://g.gravizo.com/g?
  digraph G {
      rankdir=LR;
      	compound=true;
      	node [shape="record" style="filled"];
      	splines=line;
      	Client [fillcolor="aliceblue"];
      	subgraph cluster {
      		label="3-Nodes Docker Swarm Cluster";
      		"Traefik" [fillcolor="aliceblue"];
      		"Swarm LB" [fillcolor="aliceblue"];
      		subgraph cluster_0 {
      			label="QuantumLeap";
                QL2 [fillcolor="aliceblue"];
                QL1 [fillcolor="aliceblue"];
                QL3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="CrateDB stack";
      			Crate1 [fillcolor="aliceblue"];
      			Crate2 [fillcolor="aliceblue"];
      			Crate3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_2 {
      			label="Grafana";
      			Grafana1 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> "Swarm LB" [label="8668",lhead=cluster_0];
      	Client -> "Traefik" [label="4200",lhead=cluster_0];
      	Client -> "Grafana1" [label="3000",lhead=cluster_0];
      	"Swarm LB" -> {QL1,QL2,QL3};
      	Traefik -> Crate1 [lhead=cluster_1];
        Grafana1 -> Crate1 [lhead=cluster_1];
      	QL1 -> Crate1 [lhead=cluster_1];
      	QL2 -> Crate1 [lhead=cluster_1];
      	QL3 -> Crate1 [lhead=cluster_1];
      	Crate1 -> {Crate2, Crate3} [dir="both"];
        Crate2 -> {Crate3} [dir="both"];
  }
'>


## A Simple Walkthrough

#### Before Starting

Before we launch the stack, you need to define a domain for the entrypoint of your docker cluster. Save that domain in an environment variable like this:

    $ export CLUSTER_DOMAIN=mydomain.com

If you are just testing locally and don't own one, you can fake it editing your /etc/hosts file to add an entry that points to the IP of any of the nodes of your Swarm Cluster. See the example below.

    # End of /etc/hosts file
    192.168.99.100  mydomain.com
    192.168.99.100  crate.mydomain.com

Note we've included one entry for crate because we'll be accessing the CrateDB cluster UI through the [Traefik](https://traefik.io) proxy.

#### Deploy

Now, we're ready to launch the stack with the name "ql".

    $ docker stack deploy -c docker-compose ql

Wait until you see all instances up and running (this might take some minutes).

    $ docker service ls
    ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
    2vbj18blsqje        ql_traefik          global              1/1                 traefik:1.3.5-alpine              *:80->80/tcp,*:443->443/tcp,*:4200->4200/tcp,*:4300->4300/tcp,*:8080->8080/tcp
    bvs32e81jcns        ql_viz              replicated          1/1                 dockersamples/visualizer:latest   *:8282->8080/tcp
    e8kyp4vylvev        ql_quantumleap      replicated          1/1                 smartsdk/quantumleap:latest       *:8668->8668/tcp
    ignls7l57hzn        ql_crate            global              3/3                 crate:1.0.5                       
    tfszxc2fcmxx        ql_grafana          replicated          1/1                 grafana/grafana:latest            *:3000->3000/tcp


#### Explore

Now, if you open your explorer to http://crate.mydomain.com you should see the CRATE.IO dashboard. In the "cluster" tab you should see the same number of nodes you have in the swarm cluster.

For a quick test, you can use the *insert.sh* script in this folder.

    $ sh insert.sh IP_OF_ANY_SWARM_NODE 8668

Otherwise, open your favourite API tester and send the fake notification shown below to QuantumLeap to later see it persisted in the database through the Crate Dashboard.

    # Simple fake payload to send to IP_OF_ANY_SWARM_NODE:8668.
    {
        "subscriptionId": "5947d174793fe6f7eb5e3961",
        "data": [
            {
                "id": "Room1",
                "type": "Room",
                "temperature": {
                    "type": "Number",
                    "value": 27.6,
                    "metadata": {
                        "dateModified": {
                            "type": "DateTime",
                            "value": "2017-06-19T11:46:45.00Z"
                        }
                    }
                }
            }
        ]
    }

For further information, please refer to the [QuantumLeap's User Manual](https://smartsdk.github.io/ngsi-timeseries-api/).
