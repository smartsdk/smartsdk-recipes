# Backend Device Management (IDAS)

For more info about this Chapter, see [here]( https://catalogue.fiware.org/chapter/internet-things-services-enablement).

For more info about this GE, see [here](https://catalogue.fiware.org/enablers/backend-device-management-idas).

## IoT Agents

**Why using an IoT Agent?**

- Transform IoT Device specific protocol to NGSI (a.k.a Active attributes)
- Request data from the IoT Device at some intervals (a.k.a Lazy attributes)
- Execute commands on the IoT Device communication based on context in the Broker (see Commands).

Explore the subfolders of each of the available IoT Agent recipes. The Agents can be considered stateless services and hence be deployed in the replicated mode of swarm with any required amount of replicas, provided that you keep your configurations using the service name of the agent for routing purposes.

For good scalability, when deploying the mongo databases that your agents may use in case of persistence need, make sure you deploy with the provided recipe for mongo replica sets. More info [here](../utils/mongo-replicaset/readme.md).

**Testing**

If you would like to try the IoT Agents in a local development enviroment, you can deploy the complementary services (Orion, Mongo, etc) in a simplistic way using the *testing-support.yml* file in this folder.

    docker stack deploy -c testing-support.yml iota-sup
    
_**IMPORTANT:**_ testing-support.yml is only meant to be used in testing scenarios. For more production-like deployments of the services listed in testing-support.yml, please refer to the recipes of the corresponding Generic Enablers.

If you are following the step-by-step of the official documentation guides, you may find the scripts in the ```test``` subfolders useful. Remember you no longer have everything running in local host so you will have to adjust the urls sometimes. You can use the service names if you are inside the docker network or the IP of your docker swarm node (any of them) if you are outside the cluster. Checkout the setup.sh.
