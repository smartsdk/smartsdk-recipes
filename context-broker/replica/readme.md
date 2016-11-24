# Steps
1) [x] Run orion with mongo using docker containers locally
2) [x] Same as before but guarantee data persistence after containers reset.
3) [x] Introduce mongo replica set to the previous scenario
4) [x] Test all cases
5) Now distribute the containers in different hosts (docker-machine?)
6) Add authentication for the db? (shouldn't orion take care of that?)
7) Parametrize all ad-hoc strings
8) Run automated tests
9) Update docs

# Testing

## Testing within mongo
Enter the mongo console from the mongo container like this:
    $ docker exec -it mongo1 bash
    $ mongo
    $ user orion
    $ db.entities.find({})

Tests I'd do:
 - Setup replica3. And insert something in orion.
 - Query all instances for that info
 - Kill master and query again for info
 - Restart containers and query data again (i.e, test persistence)

# Known issues (TODO)
 - Orion needs to wait for mongo1.
    Currently there is no solution for this within docker-compose, so a script
    will have to be added to deal with this. For now I'm just doing
    docker-compose restart orion.
    # http://stackoverflow.com/questions/31746182/docker-compose-wait-for-container-x-before-starting-y
 - Is mongosetup failing?

# Open Questions:
 - When going to distributed stage, how to configure IPS of the db instances?
    - script can query ip based on container name
 - How to automate steps executed within a container on the mongo console?
    - can use a mongo config file to be loaded
 - How to manage authentication to the dbs?
 - Will orion loose connection to mongo when the primary is changed?
    - Yes, if using -rplSet param

# Resources
 - [mongoDB replicas](https://docs.mongodb.com/manual/replication/)
 - https://medium.com/@gargar454/deploy-a-mongodb-cluster-in-steps-9-using-docker-49205e231319#.mcu0vzbse
 - http://www.sohamkamani.com/blog/2016/06/30/docker-mongo-replica-set/
 - http://www.emergingafrican.com/2016/02/deploying-mongodb-replica-sets-with.html
 - http://stackoverflow.com/questions/27187591/deploy-mongodb-replicaset-servers-with-docker-on-different-physical-servers
 - https://www.mongodb.com/blog/post/running-mongodb-as-a-microservice-with-docker-and-kubernetes
