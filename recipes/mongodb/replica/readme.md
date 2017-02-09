# MongoDB replica-set

This recipe aims to deploy and control a [replica set](https://docs.mongodb.com/manual/replication/) of MongoDB instances in a Docker Swarm.

ATTENTION: This recipe is not yet ready for production environments. See further improvements section for more details

##### How to use

    $ docker stack deploy -c docker-compose.yml mongo-replica

Allow some time while images are pulled in the nodes. After a couple of minutes, all services should be up and running. You can check if all replicas were deployed by running...

    $ docker service ls

You can check for error messages inspecting the logs of the mongo-replica_mongo-controller service. This can be done with either

    $ docker service logs mongo-replica_mongo-controller

or, running docker log container_id on the host running the mongo-controller.

##### How it works

The recipe consists of basically two services, namely, one for mongo instances and one for controlling the replica-set.

The mongo service is deployed in "global" mode, meaning that it will run one instance of mongod per swarm node in the cluster.

At the master node, a python-based controller script will be deployed to configure and maintain the replica-set.

For further details, refer to the *docker-compose.yml* file or *scripts/replica_ctrl.py*

##### Challenges and Further improvements

The main challenge for this script was to know at runtime where each mongod instance was running so as to configure the replica-set properly. The idea of the new orchestration features in swarm is that you really shouldn't care where they run as long as swarm keeps them up and running. But mongo needs to know that. The same problem applies for containers running services exposed to the outer world (see for instance [this issue](https://github.com/docker/swarm/issues/1106)).

So the first approach is to find out this information from the docker api. Also, since the recipe is expected to be self-contained and work without dependencies on things running outside the swarm, we need to get this information from a container running in the swarm. My understanding is that such an introspective api to safely retrieve this kind of information is yet to come (e.g [this issue](https://github.com/docker/docker/issues/8427) and related ones such as [this one](https://github.com/docker/docker/issues/1143#issuecomment-233152700)). So for now this is depending on access to the host's docker socket **(terribly insecure workaround)**.

Further things to keep in mind:

- At the moment this recipe does not include a data persistence solution, so if a cluster node fails for some reason, data will be lost. Of course, solving data-persistence related issues is in the roadmap of all recipes.

- Consider using authentication in the replica-set.
