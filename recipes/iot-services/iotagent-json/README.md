# IoT Agent (JSON)

Official documentation of this IoT Agent: http://fiware-iotagent-json.readthedocs.io/en/latest/index.html

## MQTT Transport

### What you can customise

##### Via ENV variables

- MOSQUITTO_VERSION: Version number (tag) of the [Mosquitto Docker Image](https://hub.docker.com/_/eclipse-mosquitto/).
- IOTA_VERSION: Version number (tag) of the [Agent Docker Image](https://hub.docker.com/r/telefonicaiot/iotagent-json/~/dockerfile/).

##### Via Files
- config.js: Feel free to edit this file before deployment, it will be used by the agent as its config file. It is treated by docker as a [config](https://docs.docker.com/compose/compose-file/#configs).

- mosquitto.conf: Feel free to edit this file before deployment, it will be used by mosquitto as its config file. It is treated by docker as a [config](https://docs.docker.com/compose/compose-file/#configs).

### Deploying this recipe

We assume you have already setup your environment as explained in the [Installation](../installation.md).

    docker stack deploy -c docker-compose.yml iota-json

The deployed services will be:

- [IoTAgent-json](https://github.com/telefonicaid/iotagent-json)
- [Mosquitto](http://mosquitto.org/) as MQTT Broker


### Important Things to keep in mind

- As of today, the official Mosquitto Docker Image is not including the mosquitto-clients, so if you want to execute commands like ```mosquitto_sub``` and ```mosquitto_pub```, you basically have 2 options:
    - Install them in your system and add the host parameter to point to the docker mosquitto service.
    
    - Install the clients in the mosquitto container. Note this will not persist after a container restart! If you need this to persist create your docker image accordingly. 
            docker exec -ti mosquitto_container sh -c "apk --no-cache add mosquitto-clients"    

### TODO
- Complete testing of the step-by-step guide to make sure this recipe provides all the minimum requirements for a first successful walkthrough with the Agent. Depends on [this issue](https://github.com/telefonicaid/iotagent-json/issues/222).