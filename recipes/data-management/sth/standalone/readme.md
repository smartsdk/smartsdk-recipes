# Standalone

## Introduction

The idea of this standalone walkthrough is to test and showcase the Comet
Generic Enabler within a simple notification-based scenario, like the one
illustrated below.

<img src='http://g.gravizo.com/g?
digraph Cluster {
    label="Docker Swarm"
    rankdir=LR;
    compound=true;
    node [shape="record" style="filled" fillcolor=aliceblue];
    splines=line;
    "Client" [shape=oval];
    "Orion";
    "Orion DB" [shape=egg];
    "Comet LB";
    Comet1;
    Comet2;
    Comet3;
    "Comet DB" [shape=egg];
    "Orion" -> "Comet LB";
    "Orion" -> "Comet LB";
    "Orion" -> "Comet LB" [label="NGSI Notifications"];
    "Orion DB" -> "Orion"[dir=both];
    "Client" -> "Orion" [label=1026];
    "Client" -> "Comet LB" [label=8666];
    "Comet LB" -> {Comet1,Comet2,Comet3};
    "Comet2" -> "Comet DB";
    "Comet1" -> "Comet DB";
    "Comet3" -> "Comet DB";
    {rank=same; "Orion"; "Orion DB";}
}
'>

## A walkthrough

Firstly, you need to have a Docker Swarm (docker >= 1.13) already setup. If you
don't have one, checkout the [tools](../../../tools/readme.md) section for a
quick way to setup a local swarm.

```
    $ miniswarm start 3
    $ eval $(docker-machine env ms-manager0)
```

To start the whole stack simply run, as usual:

```
    $ docker stack deploy -c docker-compose.yml comet
```

Then, wait until you see all the replicas up and running:

```
    $ docker service ls
    ID            NAME               MODE        REPLICAS  IMAGE
    1ysxmrxrqvp4  comet_comet-mongo  replicated  1/1       mongo:3.2
    8s9acybjxo0m  comet_orion        replicated  1/1       fiware/orion:latest
    ra84eex0zsd0  comet_comet        replicated  3/3       telefonicaiot/fiware-sth-comet:latest
    xg8ds3szkoi7  comet_orion-mongo  replicated  1/1       mongo:3.2
```

Now let's start some checkups. For convenience, let's save the IP address of
the Orion and Comet services. In this scenario, since both are deployed on
Swarm exposing their services ports, only one entry-point to the Swarm's
ingress network will suffice.

```
    ORION=http://$(docker-machine ip ms-manager0)
    COMET=http://$(docker-machine ip ms-manager0)
```

Let's start some checkups, first making sure Orion is up and running.

```
    $ sh ../../context-broker/query.sh $ORION
    {
    "orion" : {
      "version" : "1.7.0-next",
      "uptime" : "0 d, 0 h, 1 m, 39 s",
      "git_hash" : "f710ee525f0fa55f665e578e309fc716c12cfd99",
      "compile_time" : "Wed Feb 22 10:14:18 UTC 2017",
      "compiled_by" : "root",
      "compiled_in" : "b99744612d0b"
    }
    }
    []
```

Let's insert some simple data (Room1 measurements):

```
    $ sh ../../context-broker/insert.sh $ORION
```

Now, let's subscribe Comet to the notifications of changes in temperature
of Room1.

```
    $ sh ../subscribe.sh $COMET
    {
      "subscribeResponse" : {
        "subscriptionId" : "58b98c0cdb69948641065907",
        "duration" : "PT24H"
      }
    }
```

Let's update the temperature value in Orion...

```
    $ sh ../../context-broker/update.sh $ORION
```

And check you can see the Short-Term-Historical view of both measurements.

```
    $ sh ../query_sth.sh $COMET
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
                                    "recvTime": "2017-03-03T15:30:20.650Z"
                                },
                                {
                                    "attrType": "Float",
                                    "attrValue": 29.3,
                                    "recvTime": "2017-03-03T15:32:48.741Z"
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
