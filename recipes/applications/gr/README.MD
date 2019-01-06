# Green Route

## Introduction

TODO

## Deployment

Green Route consists of a series of different microservices that need to be
deployed using Docker.

It requires that you create the usual "backend" and "frontend" overlay networks.
See [the Creating Networks section here](../../installation.md) for more
details.

TODO: Comment here on required environment variables setting (if any).

### On a Single Node

If you only have one machine (which requires at least 8GB of RAM), you can
deploy all services at once using the [docker-compose-single.yml](./docker-compose-single.yml)
file found in this folder.

So, from the command line, execute the following command:

```bash
docker stack deploy -c docker-compose-single.yml greenroute
```

Otherwise, from the Platform Manager, deploy the **"Green Route Single"** App
Template (TODO).

### On multiple Nodes (HA)

In this scenario, you first need to deploy a MongoDB replicaset. This is
covered by the [MongoDB Recipe](../../utils/mongo-replicaset/readme.md).

Then, you deploy [Orion](../../data-management/context-broker/readme.md) and [Quantumleap](../../data-management/quantumleap/readme.md)
independently. For convenience, you can simply use the [docker-compose-ha-base.yml](.docker-compose-ha-base.yml)
file as follows:

```bash
docker stack deploy -c docker-compose-ha-base.yml greenroute
```

Finally, you need to deploy Green Route specific services.

From the command line, execute the following command:

```bash
docker stack deploy -c docker-compose-ha.yml greenroute
```

Otherwise, from the Platform Manager you can deploy the **"Green Route HA"**
App Template (TODO).
