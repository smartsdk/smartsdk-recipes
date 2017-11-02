# IoT Agent (UL)

Official documentation of this IoT Agent: http://fiware-iotagent-ul.readthedocs.io/en/latest/index.html

## HTTP Transport

### What you can customise

##### Via ENV variables

- IOTA_VERSION: Version number (tag) of the [Agent Docker Image](https://hub.docker.com/r/telefonicaiot/iotagent-ul/~/dockerfile/).

##### Via Files
- config.js: Feel free to edit this file before deployment, it will be used by the agent as its config file. It is treated by docker as a [config](https://docs.docker.com/compose/compose-file/#configs).


### Deploying this recipe

We assume you have already setup your environment as explained in the [Installation](../installation.md).

    docker stack deploy -c docker-compose.yml iota-ul

The deployed services will be:

- [IoTAgent-ul](https://github.com/telefonicaid/iotagent-ul)
