# Green Route

## Introduction

Green Route is focused on supporting the citizen mobility in high polluted cities
with the aim of improving the life quality of citizens and fostering 
environmental friendly behaviors by citizens. The objective of Green Route is to help
the final user to determine the best route to reach a destination, taking
into account the user profile and user preferences such as transport type.

## Deployment

Green Route consists of a series of different microservices that need to be
deployed using Docker.

It requires that you create the usual "backend" and "frontend" overlay networks.
See [the Creating Networks section here](../../installation.md) for more
details.

In order to configure the frontend and backend services, it is necessary to define a set
of environment variables as shown below:

#### gr-backend

- GR_MONGO_HOST: Reference to MongoDB service (mongo:27017)
- REPLICASET_NAME: Name of mongo replicaset (rs)
- GR_KEYROCK_URL: Reference to Keyrock service (http://keyrock:5000)
- GR_ORION_URL: Reference to Orion subdomain (https://orion.mydomain.com)
- GR_DOMAIN_URL: Domain (mydomain.com)

#### gr-frontend

- GR_BACKEND_URL: Reference to backend subdomain (https://api.mydomain.com/back-sdk)
- GR_GRAFANA_URL: Reference to grafana subdomain (https://grafana.mydomain.com/dashboard/db/airquality-dashboard)
- GR_ALERTS_URL=: Reference to alerts application subdomain (https://alerts.mydomain.com)
- GR_ROUTINGMAP_URL: Reference to map application subdomain (https://map.mydomain.com/)

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
