# HA

### Introduction

Let's test a deployment of Comet with multiple replicas in both its front-end
and backend. The idea now is to get the scenario illustrated below.

<img src='http://g.gravizo.com/g?
digraph Cluster {
    label="Docker Swarm"
    rankdir=LR;
    compound=true;
    node [shape="record" style="filled" fillcolor=aliceblue];
    splines=line;
    "Client" [shape=oval];
    "NGSI";
    "Comet LB";
    Comet1;
    Comet2;
    Comet3;
    "Comet DB 1" [shape=egg];
    "Comet DB 2" [shape=egg];
    "Comet DB 3" [shape=egg];
    "NGSI" -> "Comet LB" [label="Notifications"];
    "Client" -> "Comet LB" [label=8666];
    "Comet LB" -> {Comet1,Comet2,Comet3};
    "Comet2" -> "Comet DB 1";
    "Comet1" -> "Comet DB 1";
    "Comet3" -> "Comet DB 1";
    "Comet DB 1" -> "Comet DB 2" [dir=both];
    "Comet DB 2" -> "Comet DB 3" [dir=both];
    "Comet DB 1" -> "Comet DB 3" [dir=both];
    {rank=same; "Comet DB 2"; "Comet DB 3"}
}
'>

Later, this could be combined for example with an
[HA deployment of Orion Context Broker](../../context-broker/ha/readme.md).

### A walkthrough

First, you need to have a Docker Swarm (docker >= 1.13) already setup. If you
don't have one, checkout the [tools](../../../tools/readme.md) section for
a quick way to setup a local swarm.

```
    miniswarm start 3
    eval $(docker-machine env ms-manager0)
```

Comet needs a mongo database for its backend. If you have already deployed
Mongo within your cluster and would like to reuse that database, you can skip
the next step (deploying backend). You will just need to pay attention to
the variables you define for Comet to link to Mongo, namely,
`MONGO_SERVICE_URI` and `REPLICASET_NAME`. Make sure you have the correct
values in `frontend.env`. The value of `MONGO_SERVICE_URI` should be a routable
address for mongo. If deployed within the swarm, the service name (with stack
prefix) would suffice. You can read more in the
[official docker docs](https://docs.docker.com/docker-cloud/apps/service-links/).
The default values should be fine for you if you used the
[Mongo Replicaset Recipe](../../../utils/mongo-replicaset/readme.md).

Otherwise, if you prefer to make a new deployment of Mongo just for Comet, you
can take a shortcut and run...

```
    sh deploy_back.sh
```

After a while, when the replica-set is ready, you can deploy comet by running...

```
    sh deploy_front.sh
```

Now, as usual, a brief test to confirm everything is properly connected.
As a source of notifications, we have deployed Orion in the swarm (see
[Orion in HA](../../context-broker/ha/readme.md) for example).

For convenience, let's save the IP address of the Orion and Comet services.
In this scenario, since both are deployed on Swarm exposing their services
ports, only one entry-point to the Swarm's ingress network will suffice.

```
    ORION=http://$(docker-machine ip ms-manager0)
    COMET=http://$(docker-machine ip ms-manager0)
```

Insert:

```
    sh ../../context-broker/insert.sh $ORION
    sh ../../context-broker/query.sh $ORION
    ...
```

Subscribe:

```
    sh ../subscribe.sh $ORION
    {
      "subscribeResponse" : {
        "subscriptionId" : "58bd1940b97cc713f5eacdb7",
        "duration" : "PT24H"
      }
    }
```

Update:

```
    sh ../../context-broker/update.sh $ORION
```

And voila:

```
    sh ../query_sth.sh $COMET
    {
    "contextResponses": [
        {
            "contextElement": {
                "attributes": [
                    {
                        "name": "temperature",
                        "values": [
                            {
                                "attrType": "Float",
                                "attrValue": 23,
                                "recvTime": "2017-03-06T08:09:36.493Z"
                            },
                            {
                                "attrType": "Float",
                                "attrValue": 29.3,
                                "recvTime": "2017-03-06T08:11:14.044Z"
                            }
                        ]
                    }
                ],
                "id": "Room1",
                "isPattern": false,
                "type": "Room"
            },
            "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
            }
        }
    ]
    }
```
