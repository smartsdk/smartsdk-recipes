# API Umbrella in HA

This recipe shows how to deploy an scalable
[API Umbrella instance](https://github.com/telefonicaid/fiware-orion/blob/master/README.md)
service backed with an scalable
[replica set](https://docs.mongodb.com/v3.2/replication/) of MongoDB instances.

All elements will be running in docker containers, defined in docker-compose
files. Actually, this recipe focuses on the deployment of the API Umbrella
frontend, reusing the [mongodb replica recipe](../../utils/mongo-replicaset/readme.md)
as its backend.

At the time being, other services, such as [Elastic Search](https://www.elastic.co/products/elasticsearch)
for logging api interactions and QoS are not deployed.
This is mostly due to the fact that API Umbrella supports only obsolete versions
of Elastic Search (i.e. version 2, while current version is 6).

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
      			label="API Umbrella stack";
      			APIUmbrella1 [fillcolor="aliceblue"];
      			APIUmbrella2 [fillcolor="aliceblue"];
      			APIUmbrella3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="MongoDB Replica Set stack";
      			Mongo1 [fillcolor="aliceblue"];
      			Mongo2 [fillcolor="aliceblue"];
      			Mongo3 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> "Load Balancer" [label="80",lhead=cluster_0];
      	"Load Balancer" -> {APIUmbrella1,APIUmbrella2,APIUmbrella3};
      	APIUmbrella1 -> Mongo1 [lhead=cluster_1];
      	APIUmbrella2 -> Mongo1 [lhead=cluster_1];
      	APIUmbrella3 -> Mongo1 [lhead=cluster_1];
      	Mongo1 -> {Mongo2, Mongo3} [dir="both"];
  }
'>

## Prerequisites

Please make sure you read the [welcome page](../../index.md) and followed
the steps explained in the [installation guide](../../installation.md).

## How to use

Firstly, you need to have a Docker Swarm (docker >= 17.06-ce) already setup.
If you don't have one, checkout the [tools](../../tools/readme.md) section
for a quick way to setup a local swarm.

```
$ miniswarm start 3
$ eval $(docker-machine env ms-manager0)
```

In case you haven't done it yet for other recipes, deploy `backend` and
`frontend` networks as described in the
[installation guide](../../installation.md#creating-the-networks).

API Umbrella needs a mongo database for its backend. If you have already
deployed Mongo within your cluster and would like to reuse that database, you
can skip the next step (deploying backend).
You will just need to pay attention to the variables
you define for API Umbrella to link to Mongo, namely, `MONGO_SERVICE_URI`
and `REPLICASET_NAME`.

Otherwise, if you prefer to make a new deployment of MongoDB just for API
Umbrella, you can take a shortcut and run...

```bash
$ sh deploy_back.sh

Creating config mongo-rs_mongo-healthcheck
Creating service mongo-rs_mongo
Creating service mongo-rs_controller
```

Beside that, given that Ruby driver for MongoDB is not supporting service
discovery, you will need to expose the ports of the MongoDB server on the
cluster to allow the connection to the Replica Set from API Umbrella.

Be aware that this works only when you deploy (as in the script), your MongoDB
in global mode.

```bash
$ docker service update --publish-add published=27017,target=27017,protocol=tcp,mode=host mongo-rs_mongo

mongo-rs_mongo
overall progress: 1 out of 1 tasks 
w697ke0djs3c: running   [==================================================>] 
verify: Service converged
```

Wait some time until the backend is ready, you can check the backed deployment
running:

```bash
$ docker stack ps mongo-rs
ID                  NAME                                       IMAGE                              NODE                DESIRED STATE       CURRENT STATE             ERROR               PORTS
mxxrlexvj0r9        mongo-rs_mongo.z69rvapjce827l69b6zehceal   mongo:3.2                          ms-worker1          Running             Starting 9 seconds ago                        
d74orl0f0q7a        mongo-rs_mongo.fw2ajm8zw4f12ut3sgffgdwsl   mongo:3.2                          ms-worker0          Running             Starting 15 seconds ago                       
a2wddzw2g2fg        mongo-rs_mongo.w697ke0djs3cfdf3bgbrcblam   mongo:3.2                          ms-manager0         Running             Starting 6 seconds ago                        
nero0vahaa8h        mongo-rs_controller.1                      martel/mongo-replica-ctrl:latest   ms-manager0         Running             Running 5 seconds ago
```

Set the connection url for mongo based on the IPs of your Swarm Cluster
(alternatively edit the `frontend.env` file):

```bash
$ MONGO_REPLICATE_SET_IPS=192.168.99.100:27017,192.168.99.101:27017,192.168.99.102:27017
$ export MONGO_REPLICATE_SET_IPS
```

If you used `miniswarm` to create your cluster, you can get the different IPs
using the `docker-machine ip` command, e.g.:

```bash
$ docker-machine ip ms-manager0

$ docker-machine ip ms-worker0

$ docker-machine ip ms-worker1
```

when all services will be in status ready, your backend is ready to be used:

```bash
$ sh deploy_front.sh

generating config file
replacing target file  api-umbrella.yml
replace mongodb with mongo-rs_mongo
replacing target file  api-umbrella.yml
replace rs_name with rs
Creating config api_api-umbrella
Creating service api_api-umbrella
```

When also the frontend services will be running, your deployment
will look like this:

```bash
$ docker service ls

ID                  NAME                  MODE                REPLICAS            IMAGE                                 PORTS
ca11lmx40tu5        api_api-umbrella      replicated          2/2                 martel/api-umbrella:0.14.4-1-fiware   *:80->80/tcp,*:443->443/tcp
te1i0vhwtmnw        mongo-rs_controller   replicated          1/1                 martel/mongo-replica-ctrl:latest      
rbo2oe2y0d72        mongo-rs_mongo        global              3/3                 mongo:3.2
```

If you see `3/3`in the replicas column it means the 3 out of 3 planned replicas
are up and running.

## A walkthrough

In the following walkthrough we will explain how to do the initial configuration
of API Umbrella and register your first API. For more details read 
[API Umbrella's documentation](https://api-umbrella.readthedocs.io/en/latest/).

1. Let's create the admin user in API Umbrella. As first thing,
    get the IP of your master node:

    ```bash
    $ docker-machine ip ms-manager0
    ```

    Open the browser at the following endpoint:
    `http://<your-cluster-manager-ip>/admin`.

    Unless you also created certificates for your server, API Umbrella
    will ask you to accept the connection to an insecure instance.

    In the page displayed you can enter the admin user name and the password.

    Now you are logged in and you can configure the backend APIs.

    **N.B.:** The usage of the cluster master IP is just a convention, you can
    reach the services also at the IPs of the worker nodes.

1. Retrieve `X-Admin-Auth-Token` Access and `X-Api-Key`.
    In the menu select `Users->Admin Accounts` and click on the username
    you just created. Copy the `Admin API Access` for your account.

    In the menu select `Users->Api Users` click on the username
    `web.admin.ajax@internal.apiumbrella` and copy the API
    Key (of course you can create new ones instead of reusing API Umbrella
    defaults).

1. Register an new API. Create a simple API to test that everything works:

    ```bash
    $ curl -k -X POST "https://<your-cluster-manager-ip>/api-umbrella/v1/apis" \
      -H "X-Api-Key: <your-API-KEY>" \
      -H "X-Admin-Auth-Token: <your-admin-auth-token>" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" -d @- <<EOF
    {
      "api": {
        "name": "distance FIWARE REST",
        "sort_order": 100000,
        "backend_protocol": "http",
        "frontend_host": "<your-cluster-manager-ip>",
        "backend_host": "maps.googleapis.com", 
        "servers": [
          {
            "host": "maps.googleapis.com",
            "port": 80
          }
        ],
        "url_matches": [
          {
            "frontend_prefix": "/distance2/",
            "backend_prefix": "/"
          }
        ],
        "balance_algorithm": "least_conn",
        "settings": {
          "require_https":"required_return_error",
          "require_idp": "fiware-oauth2",
          "disable_api_key":"false",
          "api_key_verification_level":"none",
          "rate_limit_mode":"unlimited",
          "error_templates": {},
          "error_data": {}
        }    
      }
    }
    EOF

    Response:
    {
      "api": {
        "backend_host": "maps.googleapis.com",
        "backend_protocol": "http",
        "balance_algorithm": "least_conn",
        "created_at": "2018-02-26T13:47:02Z",
        "created_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
        "deleted_at": null,
        "frontend_host": "<your-cluster-manager-ip>",
        "name": "distance FIWARE REST",
        "servers": [
          {
            "host": "maps.googleapis.com",
            "port": 80,
            "id": "f0f7a039-d88c-4ef8-8798-a00ad3c8fcdb"
          }
        ],
        "settings": {
          "allowed_ips": null,
          "allowed_referers": null,
          "anonymous_rate_limit_behavior": null,
          "api_key_verification_level": "none",
          "api_key_verification_transition_start_at": null,
          "append_query_string": null,
          "authenticated_rate_limit_behavior": null,
          "disable_api_key": false,
          "error_data": null,
          "error_templates": {},
          "http_basic_auth": null,
          "pass_api_key_header": null,
          "pass_api_key_query_param": null,
          "rate_limit_mode": "unlimited",
          "require_https": "required_return_error",
          "require_https_transition_start_at": null,
          "require_idp": "fiware-oauth2",
          "required_roles": null,
          "required_roles_override": null,
          "error_data_yaml_strings": {},
          "headers_string": "",
          "default_response_headers_string": "",
          "override_response_headers_string": "",
          "id": "4dfe22af-c12a-4733-807d-0a668c413a96",
          "default_response_headers": null,
          "headers": null,
          "override_response_headers": null,
          "rate_limits": null
        },
        "sort_order": 100000,
        "updated_at": "2018-02-26T13:47:02Z",
        "updated_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
        "url_matches": [
          {
            "backend_prefix": "/",
            "frontend_prefix": "/distance2/",
            "id": "ec719b9f-2020-4eb9-8744-5cb2bae4b625"
          }
        ],
        "version": 1,
        "id": "cbe24047-7f74-4eb5-bd7e-211c3f8ede22",
        "rewrites": null,
        "sub_settings": null,
        "creator": {
          "username": "xxx"
        },
        "updater": {
          "username": "xxx"
        }
      }
    }
    EOF
    ```

1. Publish the newly registered API.

    ```bash
    $ curl -k -X POST "https://<your-cluster-manager-ip>/api-umbrella/v1/config/publish" \
      -H "X-Api-Key: <your-API-KEY>" \
      -H "X-Admin-Auth-Token: <your-admin-auth-token>" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" -d @- <<EOF
    {
      "config": {
        "apis": {
          "cbe24047-7f74-4eb5-bd7e-211c3f8ede22": {
            "publish": "1"
          }
        },
        "website_backends": {
        }
      }
    }
    EOF

    Response:

    {
      "config_version": {
        "config": {
          "apis": [
            {
              "_id": "cbe24047-7f74-4eb5-bd7e-211c3f8ede22",
              "version": 2,
              "deleted_at": null,
              "name": "distance FIWARE REST",
              "sort_order": 100000,
              "backend_protocol": "http",
              "frontend_host": "192.168.99.100",
              "backend_host": "maps.googleapis.com",
              "balance_algorithm": "least_conn",
              "updated_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
              "updated_at": "2018-02-26T14:02:08Z",
              "created_at": "2018-02-26T13:47:02Z",
              "created_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
              "settings": {
                "require_https": "required_return_error",
                "disable_api_key": false,
                "api_key_verification_level": "none",
                "require_idp": "fiware-oauth2",
                "rate_limit_mode": "unlimited",
                "error_templates": {},
                "_id": "4dfe22af-c12a-4733-807d-0a668c413a96",
                "anonymous_rate_limit_behavior": "ip_fallback",
                "authenticated_rate_limit_behavior": "all",
                "error_data": {}
              },
              "servers": [
                {
                  "host": "maps.googleapis.com",
                  "port": 80,
                  "_id": "f0f7a039-d88c-4ef8-8798-a00ad3c8fcdb"
                }
              ],
              "url_matches": [
                {
                  "frontend_prefix": "/distance2/",
                  "backend_prefix": "/",
                  "_id": "ec719b9f-2020-4eb9-8744-5cb2bae4b625"
                }
              ]
            }
          ],
          "website_backends": []
        },
        "created_at": "2018-02-26T14:03:53Z",
        "updated_at": "2018-02-26T14:03:53Z",
        "version": "2018-02-26T14:03:53Z",
        "id": {
          "$oid": "5a9413c99f9d04008c5a0b6c"
        }
      }
    }
    ```

1. Test your new API, by issuing a query:

    * Get a token from FIWARE:

      ```bash
      $ wget --no-check-certificate https://raw.githubusercontent.com/fgalan/oauth2-example-orion-client/master/token_script.sh
      $ bash token_script.sh

      Username: your_email@example.com
      Password:
      Token: <this is the token you need>
      ```

    * Use it to make a query to your API:

      ```bash
      $ curl -k "https://<your-cluster-manager-ip>/distance2/maps/api/distancematrix/json?units=imperial&origins=Washington,DC&destinations=New+York+City,NY&token=<your-FIWARE-token>"

      Response:
      {
         "destination_addresses" : [ "New York, NY, USA" ],
         "origin_addresses" : [ "Washington, DC, USA" ],
         "rows" : [
            {
               "elements" : [
                  {
                     "distance" : {
                        "text" : "225 mi",
                        "value" : 361940
                     },
                     "duration" : {
                        "text" : "3 hours 50 mins",
                        "value" : 13816
                     },
                     "status" : "OK"
                  }
               ]
            }
         ],
         "status" : "OK"
      }
      ```

## Networks considerations

In this case, all containers are attached to the same overlay network (backend)
over which they communicate to each other. However, if you have a different
configuration and are running any of the containers behind a firewall, remember
to keep traffic open for TCP at ports 80 and 443 (API Umbrellas's default) and
27017 (Mongo's default).

When containers (tasks) of a service are launched, they get assigned an IP
address in this overlay network. Other services of your application's
architecture should not be relying on these IPs because they may change
(for example, due to a dynamic rescheduling). The good think is that docker
creates a virtual ip for the service as a whole, so all traffic to this address
will be load-balanced to the tasks addresses.

Thanks to Docker Swarm internal DNS you can also use the name of the service
to connect to. If you look at the `docker-compose.yml` file of this recipe,
orion is started with the name of the mongo service as `dbhost` param
(regardless if it was a single mongo instance of a whole replica-set).

However, to access the container from outside of the overlay network (for
example from the host) you would need to access the ip of the container's
interface to the `docker_gwbridge`. It seem there's no easy way to get that
information from the outside (see
[this open issue](https://github.com/docker/libnetwork/issues/1082).
In the walkthrough, we queried API Umbrella through one of the swarm nodes
because we rely on docker ingress network routing the traffic all the way
to one of the containerized API Umbrella services.

## Open interesting issues

* [https://github.com/docker/swarm/issues/1106](https://github.com/docker/swarm/issues/1106)

* [https://github.com/docker/docker/issues/27082](https://github.com/docker/docker/issues/27082)

* [https://github.com/docker/docker/issues/29816](https://github.com/docker/docker/issues/29816)

* [https://github.com/docker/docker/issues/26696](https://github.com/docker/docker/issues/26696)

* [https://github.com/docker/docker/issues/23813](https://github.com/docker/docker/issues/23813)

More info about docker network internals can be read at:

* [Docker Reference Architecture](https://success.docker.com/KBase/Docker_Reference_Architecture%3A_Designing_Scalable%2C_Portable_Docker_Container_Networks)
