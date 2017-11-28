# Tools

This section contains useful (and sometimes temporary) scripts as well as references to tools, projects and pieces of documentation used for the development of the recipes.

The basic environment setup is explained in the [Installation](../installation.md) part of the docs.

## Playing with Recipes?

- ### [miniswarm](https://github.com/aelsabbahy/miniswarm)
Helpful tool to help you quickly setup a local virtualbox-based swarm cluster for testing purposes.

- ### [wait-for-it](https://github.com/vishnubob/wait-for-it)
Useful shell script used when you need to wait for a service to be started.

    *Note*: This might no longer be needed since docker introduced the [healthchecks](https://docs.docker.com/engine/reference/builder/#/healthcheck) feature.

- ### [docker-swarm-visualizer](https://github.com/dockersamples/docker-swarm-visualizer)
If you'd like to have a basic view of the distribution of containers in your swarm cluster, you can use the ```visualzer.yml``` file provided in this folder.

        docker stack deploy -c visualizer.yml vis

- ### [portainer](https://portainer.readthedocs.io)
If you'd like a more sophisticated UI with info about your swarm, you can deploy portainer as follows.

        docker service create \
        --name portainer \
        --publish 9000:9000 \
        --constraint 'node.role == manager' \
        --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
        portainer/portainer \
        -H unix:///var/run/docker.sock

Alternatively, you can make use of the docker-compose file available in this folder.

    docker stack deploy -c portainer.yml portainer


- ### [postman](https://www.getpostman.com/)
A well-known tool for experimenting with APIs. Do you want to try the curl-based examples of the recipes from Postman? Import the ```postman_collection.json``` available in this folder and make your tests easier. Note: this collection is work in progress, feel free to [contribute](../contributing.md)!

## Writing Docs?

We typically write documentation in [markdown](https://daringfireball.net/projects/markdown/) format. Then, [mkdocs](http://www.mkdocs.org/) is used to generate the html format. You can see in the root of this project the `mkdocs.yml` config file.

For architecture diagrams, we use [PlantUML](http://plantuml.com/). For the diagrams we follow the conventions and leverage on the features you can find in [this project](https://github.com/smartsdk/architecture-diagrams).

Instead of uploading pictures in this document, we use [gravizo](http://www.gravizo.com)'s power to convert the .dot or PlantUML files and have them served as pictures online. There is an intermediate conversion done with [gravizo's converter](http://www.gravizo.com/#converter). Inspect the source of any recipe's `readme.md` to see an example.

Other tools for documentation that you may find useful are...
- ##### [draw.io](https://www.draw.io)
Use this tool when the diagrams start getting too complex of when you foresee the diagram will be complex from the scratch.

    Complex in the sense that making a simple change takes more time understanding the *.dot* than making a manual gui-based change.

    When using draw.io, keep the source file in the repository under a /doc subfolder of the corresponding recipe.

- ##### [color names](http://www.graphviz.org/doc/info/colors.html)
The reference for color names used in *.dot* files.

- ##### [diagramr](http://diagramr.inventage.com)
(deprecated).
To give more docker-related details we could use this tool to create diagrams from docker-compose files. The tools gives also the .dot file, which would be eventually customized and then turned into a png file using [graphviz](http://www.graphviz.org).

        $ dot compose.dot -Tpng -o compose.png
