### TASK
 [SmartSDK.Platform.Core.HA4DataManagementArchitecturePattern.HA4ContextBrokerPattern.LoadBalanceContextBroker](https://jira.fiware.org/browse/SMAR-7)

### Steps

 1. [x] Place a HAProxy in front of 1 instance of CB.
 2. [x] Place a HAProxy in front of 3 instances of CB.
 3. [] Experiment moving the scenario to a docker-swarm
 4. [] Use, per swarm node, 2 instances of HAProxy and 2 of CB.
 5. [] Use multiple instances of the db (but with the same data, e.g using replicaset)

### Known issues
- If we wanted to dynamically add more backend servers in HAProxy‘s farm we still need to restart HAProxy‘s container (and update configuration accordingly) -> checkout docker-flow-proxy
- Also, the default docker DNS server is hardcoded at 127.0.0.11 but it might change in the future. Investigate if this is exposed in docker api.
  To fix some of the issues above, we can dedicate a container to perform DNS resolution within our docker world and deliver responses to any running containers or hosts in the network.
  But wait! Docker in swarm mode incorporates an embedded DNS!.
- Compose does not use swarm mode to deploy services to multiple nodes in a swarm yet. All containers will be scheduled on the current node. To deploy the application across the swarm, let's try the bundle feature of the Docker experimental build. More info: https://docs.docker.com/compose/bundles and http://docs.master.dockerproject.org/compose/swarm/

### Resources
- https://github.com/gesellix/docker-haproxy-network
- https://docs.docker.com/engine/userguide/networking/configure-dns/
- http://blog.haproxy.com/2015/11/17/haproxy-and-container-ip-changes-in-docker/
- http://collabnix.com/archives/1610
- https://technologyconversations.com/2016/08/01/integrating-proxy-with-docker-swarm-tour-around-docker-1-12-series/
