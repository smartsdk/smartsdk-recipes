# Single Host Scenario

## Introduction

This simple recipe triggers an
[Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md)
instance backed with a [MongoDB](https://docs.mongodb.com) instance everything
running **on an single host**.

<img src='http://g.gravizo.com/g?
    digraph G {
      compound=true;
      rankdir=LR;
      ranksep=1.2;
      [fontname="times-bold",shape=plaintext];
      graph [style="filled", nodesep=0.3];
      graph [fillcolor=aliceblue];
      Client [shape=record];
      subgraph cluster_localhost {
          label="localhost"
          graph [fillcolor=aliceblue]
          subgraph cluster_mongo_container {
              label="mongo container"
              graph [fillcolor=white] {
                  node "mongod";
              }
              {
                  node [shape=tab];
                  "mongo_/data/db" [label="/data/db"];
              }
          }
          subgraph cluster_orion {
              label="orion container"
              {
                  node [shape=tab];
                  "orion_/scripts" [label="/scripts"];
              }
              graph [fillcolor=white] {
                  node "orion";
              }
          }
          subgraph cluster_hostvolumes {
              [fillcolor=white];
              label="local filesystem"
              node [shape=tab];
              "host_DATA_PATH" [label="\$DATA_PATH"];
              "host_./scripts" [label="./scripts"];
          }
      }
      "Client" -> "orion" [label="1026", lhead=cluster_orion];
      "orion" -> "mongod";
      "mongo_/data/db" -> "host_DATA_PATH";
      "orion_/scripts" -> "host_./scripts";
    }
'>

Both services will be running in docker containers, defined in the 
`[./docker-compose.yml](https://github.com/smartsdk/smartsdk-recipes/blob/master/recipes/data-management/context-broker/simple/docker-compose.yml)`
file.

Data will be persisted in a local folder defined by the value of `DATA_PATH`
variable in the
`[.env](https://github.com/smartsdk/smartsdk-recipes/blob/master/recipes/data-management/context-broker/simple/.env)`
file.

## How to use

This recipes has some default values, but optionally you can explore different
configurations by modifying the `.env` file, the `docker-compose.yml` or even
the `scripts/setup.sh`.

Then, from this folder simply run:

```
    $ docker-compose up -d
```

## How to validate

Before testing make sure docker finished downloading the images and spinning-off
the containers. You can check that by running:

```
    $ docker ps
```

You should see the two containers listed and with status "up".

Then, to test if orion is truly up and running run:

```
    $ sh ../query.sh
```

It should return something like:

```
    {
    "orion" : {
      "version" : "1.6.0-next",
      "uptime" : "0 d, 0 h, 5 m, 24 s",
      "git_hash" : "61be6c26c59469621a664d7aeb1490d6363cad38",
      "compile_time" : "Tue Jan 24 10:52:30 UTC 2017",
      "compiled_by" : "root",
      "compiled_in" : "b99744612d0b"
    }
    }
    []
```
