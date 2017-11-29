# Getting started

This recipe will show you how to deploy a default cygnus-ngsi configuration with
a MySQL backend. Note that this generic enabler can actually be deployed with
[many other backends](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-common/backends_catalogue/introduction/index.html).

This recipe in particular requires the use of [docker "configs"](https://docs.docker.com/compose/compose-file/#configs) and hence
depends on a docker-compose file version "3.3", supported in docker versions
17.06.0+.

Instructions on how to prepare your environment to test these recipes are given
in the [Installation](../../../installation.md) section of the docs. Assuming
you have created a 3-nodes Swarm setup, this deployment will look as follows...

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
            subgraph clustern3 {
          		label="Node 3";
                "Cygnus Agent 3" [fillcolor="aliceblue"];
            }
            subgraph clustern2 {
          		label="Node 2";
                "Cygnus Agent 2" [fillcolor="aliceblue"];
            }
            subgraph clustern1 {
          		label="Node 1";
                "Cygnus Agent" [fillcolor="aliceblue"];
            }
  			MySQL [fillcolor="aliceblue"];
      	}
      	Client -> "Load Balancer" [label="5050",lhead=cluster_0];
      	"Load Balancer" -> {"Cygnus Agent","Cygnus Agent 2","Cygnus Agent 3"};
      	"Cygnus Agent" -> MySQL [lhead=cluster_1];
      	"Cygnus Agent 2" -> MySQL [lhead=cluster_1];
      	"Cygnus Agent 3" -> MySQL [lhead=cluster_1];
  }
'>

As you may already know [from the docs](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-ngsi/installation_and_administration_guide/configuration_examples/index.html), in order to configure cygnus, you need to provide a
specific agent configuration file. In this case, you can customize the
`cygnus_agent.conf` and `cartodb_keys.conf` files within the `conf` folder.
The content of these files will be loaded by docker into their corresponding
configs, which will be available for all the replicas of the cygnus service.

If you inspect the `docker-compose.yml` you will realize that you can
customize the values of the MySQL user and password by setting the environment
variables `CYGNUS_MYSQL_USER` and `CYGNUS_MYSQL_PASS`.


To launch the example as it is, simply run:

```
    docker stack deploy -c docker-compose.yml cygnus
```

After a couple of minutes you should be able to see the two services up and running.
```
    $ docker service ls
    ID                  NAME                   MODE                REPLICAS            IMAGE                       PORTS
    l3h1fsk36v35        cygnus_mysql           replicated          3/3                 mysql:latest                *:3306->3306/tcp
    vmju1turlizr        cygnus_cygnus-common   replicated          3/3                 fiware/cygnus-ngsi:latest   *:5050->5050/tcp
```

For illustration purposes, let's send an NGSI notification to cygnus' entrypoint
using the simple `notification.sh` script.

```
    $ sh notification.sh http://0.0.0.0:5050/notify
    *   Trying 0.0.0.0...
    * TCP_NODELAY set
    * Connected to 0.0.0.0 (127.0.0.1) port 5050 (#0)
    > POST /notify HTTP/1.1
    > Host: 0.0.0.0:5050
    > User-Agent: curl/7.54.0
    > Content-Type: application/json; charset=utf-8
    > Accept: application/json
    > Fiware-Service: default
    > Fiware-ServicePath: /
    > Content-Length: 607
    >
    * upload completely sent off: 607 out of 607 bytes
    < HTTP/1.1 200 OK
    < Transfer-Encoding: chunked
    < Server: Jetty(6.1.26)
    <
    * Connection #0 to host 0.0.0.0 left intact
```

By now, the data sent by the script has been processed by cygnus and will be
available in the configured sink (MySQL in this case).

Having cygnus running as a service on a Docker Swarm cluster, scaling it can be
achieved as with any other docker service. For more details, refer to the
[Orion recipe](../../context-broker/ha/readme.md) to see how this can be done
with Docker. Otherwise, refer to the
[Docker service docs](https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/).

## What if I wanted a different backend?

If you wanted to try a different backend for your cygnus deployment, there are 3
steps you need to follow.

1. Configure your `cygnus_agent.conf` according to your needs. More info
[in the docs](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-ngsi/installation_and_administration_guide/configuration_examples/index.html).
1. Update the `docker-compose.yml`, specifically the environment variables
configured for the cygnus service.
For example, if you wanted to use MongoDB instead of MySQL, you'll need to
use variables CYGNUS_MONGO_USER and CYGNUS_MONGO_PASS. For a complete list
of required variables, refer to the
[cygnus docs](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-ngsi/installation_and_administration_guide/install_with_docker/index.html#section3.2).
1. Update the `docker-compose.yml`, removing the definition of the mysql service
and introducing the one of your preference. Also, don't forget to update the
`depends_on:` section of cygnus with the name of your new service.
