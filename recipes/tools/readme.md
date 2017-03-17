# Tools

This section contains useful (and sometimes temporary) scripts as well as references to tools, projects and pieces of documentation used for the development of the recipes.

The basic environment setup is explained in landing page of the repository: [https://github.com/martel-innovate/smartsdk-recipes](https://github.com/martel-innovate/smartsdk-recipes).


## Env-related

- ##### [miniswarm](https://github.com/aelsabbahy/miniswarm)

    To quickly test deployments on a local swarm. Refer to the [repo](https://github.com/aelsabbahy/miniswarm) for further details, but getting started is as simple as:

        # First-time only to install miniswarm
        $ curl -sSL https://raw.githubusercontent.com/aelsabbahy/miniswarm/master/miniswarm -o /usr/local/bin/miniswarm
        $ chmod +rx /usr/local/bin/miniswarm

        # Every time you create/destroy a swarm
        $ miniswarm start 3
        $ miniswarm delete

- ##### [wait-for-it](https://github.com/vishnubob/wait-for-it)
Useful shell script used when you need to wait for a service to be started.

    Note: This might no longer be needed since docker introduced the [healthchecks](https://docs.docker.com/engine/reference/builder/#/healthcheck) feature.

- ##### [portainer](https://portainer.readthedocs.io)
If you'd like an UI with info about your swarm:

        docker service create \
        --name portainer \
        --publish 9000:9000 \
        --constraint 'node.role == manager' \
        --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
        portainer/portainer \
        -H unix:///var/run/docker.sock

## Docs-related

- ##### [gravizo](http://www.gravizo.com)
We use this tool in the docs for **simple diagrams**. Problems with formatting? try the [converter](http://www.gravizo.com/#converter).

- ##### [draw.io](https://www.draw.io)
Use this tool when the diagrams start getting too complex of when you foresee the diagram will be complex from the scratch.

    Complex in the sense that making a simple change takes more time understanding the *.dot* than making a manual gui-based change.

    When using draw.io, keep the source file in the repository under a /doc subfolder of the corresponding recipe.

- ##### [color names](http://www.graphviz.org/doc/info/colors.html#brewer)
The reference for color names used in *.dot* files.


## Experimental
- ##### [diagramr](http://diagramr.inventage.com)
To give more docker-related details we could use this tool to create diagrams from docker-compose files. The tools gives also the .dot file, which would be eventually customized and then turned into a png file using [graphviz](http://www.graphviz.org).

        $ dot compose.dot -Tpng -o compose.png
