### TASK
 [SmartSDK.Platform.Core.HA4DataManagementArchitecturePattern.HA4ContextBrokerPattern.MongoDBReplica](https://jira.fiware.org/browse/SMAR-6)

### Steps

 1. [x] Run orion with mongo using docker containers locally
 2. [x] Same as before but guarantee data persistence after containers reset.
 3. [x] Introduce mongo replica set to the previous scenario
 4. [x] Test all cases
 5. [x] Parametrize all ad-hoc strings
 6. [ ] Distribute the containers in different hosts (Decide swarm/kubernetes)
 7. [ ] Run automated tests
 8. [ ] Update docs

### Testing

#### Ideas to test
- Setup replica3 and insert something in Orion.
- Query Orion for inserted data (test Orion-db linkage)
- Restart containers and query Orion again (test persistence)
- Query all db instances for that info (test replication was configured)
- Kill primary and query Orion again (test reelection)

#### Info for testing
 Manually inspect mongo db:

     $ docker exec -it mongo1 bash
     $ mongo
     $ use orion
     $ db.entities.find({})
Before querying secondary you need to execute

    rs.slaveOk()

#### Encountered issues and open questions
  - ~~Orion needs to wait mongo~~ _(solved)_
    - To wait for the mongo service container: used wait-for-it as suggested [here](https://docs.docker.com/compose/startup-order/).
    - To allow time for the replica to be ready: used orion's dbTimeout variable.
  - ~~How to automate steps executed within a container on the mongo console?~~ _(solved)_
     - See _setup_replica.sh_. Using rs.initiate and rs.reconfig.
     - Or a mongo config file could have been used.
  - How to deploy replicas in different hosts?
      - How to configure IPS of the db instances?
         - See *setup_repica.sh*. Script can ping by container name and dynamically get the IP.
         - Or we could use docker networks and stick with docker names.
  - Which security issues are opened with such a replica?
    - [x] Avoid "rest" option in MongoDB because it is not secure for production.

### Resources
   - [mongoDB replicas](https://docs.mongodb.com/manual/replication/)
   - [elastic-mongo](https://github.com/soldotno/elastic-mongo)
   - [sohamkani post](http://www.sohamkamani.com/blog/2016/06/30/docker-mongo-replica-set/)
   - [steve watt's post]( http://www.emergingafrican.com/2016/02/deploying-mongodb-replica-sets-with.html)
   - [stackoverflow post](http://stackoverflow.com/questions/27187591/deploy-mongodb-replicaset-servers-with-docker-on-different-physical-servers)
