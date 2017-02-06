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

docker stack deploy --compose-file=docker-compose.yml mongo-replica

- Prepare this recipe to run in a Docker Swarm.
- Use authentication: mongodb-keyfile and maybe swarm secrets.

- Deploy mongo as a "global" service (one per node)

- Problem1: How to connect to host to retrieve api info?. See [this](https://github.com/docker/docker/issues/8427), [this issue](https://github.com/docker/docker/issues/1143#issuecomment-233152700) and its derived.

  - At the host level: where would this run actually? In a rancher environment?
  - If at the containers level...:

      - Add an alias ip in the host?

      - Expose the docker socket (Dangerous)

          docker run -ti -v /var/run/docker.sock:/var/run/docker.sock joffrey/docker-py /bin/sh

      - Parse network commands to get ip of host (OS-dependent fragile solution)

- Problem2: https://github.com/docker/swarm/issues/1106
