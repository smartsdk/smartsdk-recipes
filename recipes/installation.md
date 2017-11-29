# Getting the Recipes

Get the latest version from the git repository.

```
    $ git clone https://github.com/smartsdk/smartsdk-recipes
```

# Requirements

The recipes are prepared to run using the latest
[Docker](https://docs.docker.com) version (minimum 1.13+, ideally >= 17.06.0+).
To install Docker refer to the
[Installation instructions](https://docs.docker.com/engine/installation/).

For some testing and walkthroughs, you may also need to install
[curl](https://curl.haxx.se/) if it's not already available in your system.

Finally, you should install
[VirtualBox](https://www.virtualbox.org/wiki/Downloads) if you want to create
clusters in your local environment to test the recipes (see next section).

Note For Windows Users: Many of the walkthroughs and verification steps are
designed to run tools typically found in a Linux/macOS environment.
Therefore, you will need to consider compatible workarounds from time to time.

# Preparing a Local Swarm Cluster

## Creating the Cluster

Although you can run most (if not all) of the recipes using 
[docker-compose](https://docs.docker.com/compose/install/), the recipes are
tailored to be deployed as services on Docker Swarm Clusters.

You can turn your local Docker client into a single-node Swarm cluster by simply
running

```
    $ docker swarm init
```

However, things get more interesting when you're actually working on
a multi-node cluster.

The fastest way to create one is using
[miniswarm](https://github.com/aelsabbahy/miniswarm).
Getting started is as simple as:

```
    # First-time only to install miniswarm
    $ curl -sSL https://raw.githubusercontent.com/aelsabbahy/miniswarm/master/miniswarm -o /usr/local/bin/miniswarm
    $ chmod +rx /usr/local/bin/miniswarm

    # Every time you create/destroy a swarm
    $ miniswarm start 3
    $ miniswarm delete
```

Otherwise, you can create your own using
[docker-machine](https://docs.docker.com/machine/overview/).

## Creating the networks

For convenience reasons, most if not all of the recipes will be using overlay
networks to connect the services. We have agreed-upon the convention of having
at least two overlay networks available: "backend" and "frontend". The latest
typically connects services that need some exposure to the outside world.

If you want to buy you some time, you can now create the two networks before
starting the trials with the recipes. This can be done by running the following
commands:

```
    $ docker network create -d overlay --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1400} backend
    $ docker network create -d overlay --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1400} frontend
```

Or, if you are lazy, there is a script in the `tools` folder.

```
    $ sh tools/create_networks.sh
```

Again, this is a convention to simplify the experimentation with the recipes.
In the end, you may want to edit the recipes to adapt to your specific
networking needs.


### On virtualised environments

If you are running the recipes in a virtualised environment such as your FIWARE
Lab, if at some point you experience problems with the connectivity of
the containers to the outside world, chances are that the cause of the package
dropping is due to a mismatch of the
[MTU](https://en.wikipedia.org/wiki/Maximum_transmission_unit) settings.

In FIWARE Lab, the default MTU for the vm's bridge is set to `1400`,
hence you will notice that this is the default MTU for the networks used
in the recipes.
If you need to change that value, feel free to set a `DOCKER_MTU` env variable
with the value you want before you create the networks.
