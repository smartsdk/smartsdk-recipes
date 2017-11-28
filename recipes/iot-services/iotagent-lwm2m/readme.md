# IoT Agent (LWM2M)

Official documentation of this IoT Agent:
[here](https://fiware-iotagent-lwm2m.readthedocs.io/)

## Prerequisites

Please make sure you read the [welcome page](../../index.md) and followed the steps explained in the [installation guide](../../installation.md).

## HTTP Transport

### What you can customise

#### Via ENV variables

- `IOTA_VERSION:` Version number (tag) of the
  [Agent Docker Image](https://hub.docker.com/r/telefonicaiot/lightweightm2m-iotagent/tags/).
  Defaults to `latest`.

- `IOTA_LWM2M_PORT`: Defaults to `5684`.

- `IOTA_LOG_LEVEL`: Defaults to `DEBUG`.

- `IOTA_CB_HOST`: Defaults to `orion`.

- `IOTA_CB_PORT`: Defaults to `1026`.

- `IOTA_NORTH_PORT`: Defaults to `4041`.

- `IOTA_REGISTRY_TYPE`: Defaults to `mongodb`.

- `IOTA_MONGO_HOST`: Defaults to `mongo`.

- `IOTA_MONGO_PORT`: Defaults to `27017`.

- `IOTA_MONGO_DB`: Defaults to `iotagentjson`.

- `IOTA_MONGO_REPLICASET`: Defaults to `rs`. Unset to disable replicaset option.

- `IOTA_PROVIDER_URL`: Defaults to `http://iotagent:4041`.

For the documentation of the variables please refer to the
[global configuration docs](https://github.com/telefonicaid/iotagent-node-lib/blob/master/doc/installationguide.md).

#### Via Files

- `config.js`: Feel free to edit this file before deployment, it will be used by
  the agent as its config file. It is treated by docker as a
  [config](https://docs.docker.com/compose/compose-file/#configs).

### Deploying this recipe

We assume you have already setup your environment as explained in the
[Installation](../../installation.md).

```
    docker stack deploy -c docker-compose.yml iota-lwm2m
```

The deployed services will be:

- [IoTAgent-lwm2m](https://github.com/telefonicaid/lightweightm2m-iotagent)

``Note``

If you are following the
[official step-by-step guide](https://fiware-iotagent-lwm2m.readthedocs.io/en/latest/userGuide/index.html),
you can quickly launch the lwm2m client as:

```
    docker exec -ti [AGENT_CONTAINER_ID_HERE] node_modules/lwm2m-node-lib/bin/iotagent-lwm2m-client.js
```
