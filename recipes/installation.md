# Getting the Recipes

Get the latest version from the git repository.

    $ git clone https://github.com/smartsdk/smartsdk-recipes

# Requirements

The recipes are prepared to run using the latest [Docker](https://docs.docker.com) version (minimum 1.13+, ideally 17.06.0+). To install Docker refer to the [Installation instructions](https://docs.docker.com/engine/installation/).

For some testing and walkthroughs, you may also need to install [curl](https://curl.haxx.se/) if it's not already available in your system.

Finally, you should install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) if you want to create clusters in your local environment to test the recipes (see next section).

Note For Windows Users: Many of the walkthroughs and verification steps are designed to run tools typically found in a Linux/macOS environment. Therefore, you will need to consider compatible workarounds from time to time.

# Preparing a Local Swarm Cluster

Although you can run most (if not all) of the recipes using [docker-compose](https://docs.docker.com/compose/install/), the recipes are tailored to be deployed as services on Docker Swarm Clusters.

You can turn your local Docker client into a single-node Swarm cluster by simply running

    $ docker swarm init

However, things get more interesting when you're actually working on a multi-node cluster.

The fastest way to create one is using [miniswarm](https://github.com/aelsabbahy/miniswarm). Getting started is as simple as:

    # First-time only to install miniswarm
    $ curl -sSL https://raw.githubusercontent.com/aelsabbahy/miniswarm/master/miniswarm -o /usr/local/bin/miniswarm
    $ chmod +rx /usr/local/bin/miniswarm

    # Every time you create/destroy a swarm
    $ miniswarm start 3
    $ miniswarm delete

Otherwise, you can create your own using [docker-machine](https://docs.docker.com/machine/overview/).
