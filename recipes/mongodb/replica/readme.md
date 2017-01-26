# MongoDB replica-set

This recipe will automate the creation of a [replica set](https://docs.mongodb.com/manual/replication/) of 3 MongoDB instances.

It was written for a single docker host for testing purposes. Of course, in production you don't want all the replica-set instances running in the same host.

##### How to use

    # Optionally, modify _.env_ file according to your needs.

    $ docker-compose up -d

##### How it works

There are three mongo deamons that will be triggered in their containers (mongo1, mongo2, mongo3).

A fourth container (mongosetup) will wait for _mongo1_ to be ready and then execute the *setup_replica.sh* script to configure the replica set with the 3 mongo instances.

For testing purposes, each mongo instance has its data mapped to a local directory, but this is not a strong requirement.

##### Further improvements
- Provide a more dynamic way to scale this recipe to N nodes.
- Prepare this recipe to run in a Docker Swarm.
