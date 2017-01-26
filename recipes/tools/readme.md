# Tools

This section contains useful (and sometimes temporary) scripts as well as references to tools, projects and pieces of documentation used for the development of the recipes.

### For Env
- [miniswarm](https://github.com/aelsabbahy/miniswarm): To manage a local Docker Swarm for testing purposes.
- [wait-for-it](https://github.com/vishnubob/wait-for-it): To wait for a service. Note: It might no longer be needed with the introduction of the "healthcheck" feature in docker-compose.

### For Docs
- [gravizo](http://www.gravizo.com): To create diagrams for documenting recipes.
All recipes should have an introduction with a high-level overview of what the recipe is used for. We use this tool to create such diagrams.

- [diagramr](http://diagramr.inventage.com): To give more docker-related details we use this tool to create diagrams from docker-compose files. The tools gives also the .dot file, which is eventually customized and then turned into a png file using [graphviz](http://www.graphviz.org).

        $ dot compose.dot -Tpng -o compose.png

- [color names](http://www.graphviz.org/doc/info/colors.html#brewer): The reference for color names used in .dot files.
