# Backend Device Management (IDAS)

For more info about this Chapter, see [here]( https://catalogue.fiware.org/chapter/internet-things-services-enablement).

For more info about this GE, see [here](https://catalogue.fiware.org/enablers/backend-device-management-idas).

## IoT Agents

**Why using an IoT Agent?**

- Transform IoT Device specific protocol to NGSI (a.k.a Active attributes)
- Request data from the IoT Device at some intervals (a.k.a Lazy attributes)
- Execute commands on the IoT Device communication based on context in the Broker (see Commands).

Explore the subfolders of each of the available IoT Agent recipes.

**Testing**

If you would like to try the IoT Agents in a local development enviroment, you can deploy the complementary services (Orion, Mongo, etc) in a simplistic way using the *testing-support.yml* file in this folder.

    docker stack deploy -c testing-support.yml iota-support
    
_**IMPORTANT:**_ testing-support.yml is only meant to be used in testing scenarios. For more production-like deployments of the services listed in testing-support.yml, please refer to the recipes of the corresponding Generic Enablers.