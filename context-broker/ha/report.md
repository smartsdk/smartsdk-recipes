### TASK
 [SmartSDK.Platform.Core.HA4DataManagementArchitecturePattern.HA4ContextBrokerPattern.LoadBalanceContextBroker](https://jira.fiware.org/browse/SMAR-7)

### Steps

 1. [x] Place a HAProxy in front of 1 instance of CB.
 2. [] Place a HAProxy in front of 3 instances of CB.
 3. [] Use 2 instances of HAProxy with 1 virtual IP?
 4. [] Make CB instances use the same db (or work in replica)?


### Known issues
- If we wanted to dynamically add more backend servers in HAProxy‘s farm we still need to restart HAProxy‘s container (and update configuration accordingly) #TODO: Check this.
- The default docker DNS server is hardcoded at 127.0.0.11 but it might change in the future. Investigate if this is exposed in docker api.

  To fix some of the issues above, we can dedicate a container to perform DNS resolution within our docker world and deliver responses to any running containers or hosts in the network.

### Resources
- https://github.com/gesellix/docker-haproxy-network
- https://docs.docker.com/engine/userguide/networking/configure-dns/
- http://blog.haproxy.com/2015/11/17/haproxy-and-container-ip-changes-in-docker/
