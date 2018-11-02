# Managing Deployed Services

This page explains some mechanisms that are common for the management of
services deployed with the recipes.

## Multisite Deployment

If you happen to have your cluster with nodes distributed in specific areas
(*A1, A2, ..., AN*) and you would like for the deployment of the replicas of
your service *S* to happen only in specific areas, you can achieve this by
using **placement constraints**.

For example, imagine you have a cluster composed of VMS in Málaga, Madrid and
Zurich, but you want the deployment of the replicas of your database to stay
only within Spain boundaries due to legal regulations.
(**DISCLAIMER**: This is just a simplification, you should always inform
yourself on how to properly comply with data protection regulations.)

First, you need define a labeling for the nodes of your cluster where you want
your deployment to happen. Your label in this case can be done by region.
You connect to any of the swarm manager nodes and execute the following
commands.

```bash
docker node update --label-add region=ES malaga-0
docker node update --label-add region=ES madrid-0
docker node update --label-add region=ES madrid-1

docker node update --label-add region=CH zurich-0
docker node update --label-add region=CH zurich-1
```

When you are about to deploy your database, you will have to add a constraint
to the definition of the service. This means you will have to edit the recipe
before deploying. For instance, in the case of [MongoDB](https://github.com/smartsdk/smartsdk-recipes/blob/master/recipes/utils/mongo-replicaset/docker-compose.yml),
it should have the `deploy` part looking something like this:

```yaml
mongo:
  ...
  deploy:
    placement:
      constraints:
        - region == ES
```

This was just a simple example. You can have multiple tags, combine them so
the placement only happens in nodes with all the tags, and many other
combinations. For more details of this functionality, please refer to
[the official docker docs on service placement](https://docs.docker.com/engine/swarm/services/#control-service-placement).

**Note:** For these features to work, you need access to a manager node of the
swarm cluster and Docker 17.04+.

## Scalability

As you probably already know, each recipe deploys a bunch of services, and each
service can be of any of two types: **Stateless** or **Stateful**.
The way to differentiate which type a service is, is by inspecting the
implementation of the service to tell if it needs data persistence within
itself or not.

The point is, the way to scale services depends on the type of the service.

Scaling **stateless** services with Docker is pretty straightforward, you can
simply increase the number of replicas. Assuming no constraints violations
(see previous section), you will be able to dynamically set more or less
replicas for each **stateless** service.

```bash
docker service scale orion=5
```

More info on the scaling process is documented [here](https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/).

As regards scaling **stateful** services, there is no silver bullet and it will
always depend on the service being discussed.

For example, Docker handles two types of service deployments: **replicated**
and **global**, as explained [here](https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/#replicated-and-global-services).
A **replicated** service can be scaled as shown in the previous example,
but the only way to scale a **global** service (which means there will be a
maximum of one instance per node), is by adding nodes. To scale down a
**global** service you can either remove nodes or apply constraints
(see *Multisite Deployment* section above).

In any of the two cases, for a **stateful** service, someone will have to be
responsible for coordinating the data layer among all the instances and deal
with replication, partitioning and all sort of issues typically seen in
distributed systems.

Finally, the recipes should properly document which of its services are
**stateless** and which are not, so as to have these considerations for
Scalability. They should include also, notes on how their **stateful** services
could be scaled.
