# Steps
1) Run orion with mongo using docker containers locally
2) Same as before but guarantee data persistence after containers reset.
3) Introduce mongo replica set to the previous scenario
4) Now distribute the containers in different hosts

# Testing

## Testing within mongo
Enter the mongo console from the mongo container like this:
    $ docker exec -it 4e291a5433cf bash (id of mongotest)
    $ mongo
    $ user orion
    $ db.entities.find({})

# Resources
 - https://medium.com/@gargar454/deploy-a-mongodb-cluster-in-steps-9-using-docker-49205e231319#.mcu0vzbse
 - http://www.sohamkamani.com/blog/2016/06/30/docker-mongo-replica-set/ 
 - http://www.emergingafrican.com/2016/02/deploying-mongodb-replica-sets-with.html
 - http://stackoverflow.com/questions/27187591/deploy-mongodb-replicaset-servers-with-docker-on-different-physical-servers
 - https://www.mongodb.com/blog/post/running-mongodb-as-a-microservice-with-docker-and-kubernetes
