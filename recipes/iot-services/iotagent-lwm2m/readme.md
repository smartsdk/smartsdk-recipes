# IoT Agent (LWM2M)

Official documentation of this IoT Agent: https://fiware-iotagent-lwm2m.readthedocs.io/

## HTTP Transport

### What you can customise


##### Via Files
- config.js: Feel free to edit this file before deployment, it will be used by the agent as its config file. It is treated by docker as a [config](https://docs.docker.com/compose/compose-file/#configs).


### Deploying this recipe

We assume you have already setup your environment as explained in the [Installation](../installation.md).

    docker stack deploy -c docker-compose.yml iota-lwm2m

The deployed services will be:

- [IoTAgent-lwm2m](https://github.com/telefonicaid/lightweightm2m-iotagent)


**Note**

If you are following the [official step-by-step guide](https://fiware-iotagent-lwm2m.readthedocs.io/en/latest/userGuide/index.html), you can quickly launch the lwm2m client as:

    docker exec -ti [AGENT_CONTAINER_ID_HERE] node_modules/lwm2m-node-lib/bin/iotagent-lwm2m-client.js