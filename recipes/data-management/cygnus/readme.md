# Cygnus

Here you can find recipes aimed at different usages of Cygnus, in particular,
cygnus-ngsi. We assume you are already familiar with it, but if not, refer to
the [official documentation](http://fiware-cygnus.readthedocs.io/en/latest/index.html).

Instructions on how to prepare your environment to test these recipes are given
in the [Installation](../../installation.md) section of the docs.


## Some Considerations regarding HA

The first thing to note is that when we talk about high availability while using
cygnus, we refer to the availability of data processed by cygnus agents before
it's dropped to the final storage solution. So, as you can read from the
[official documentation](http://fiware-cygnus.readthedocs.io/en/latest/index.html), 
different sinks can give you persistence in different storage solutions
(mongodb, mysql, hdfs, etc). Keeping the persisted data in HA mode is a
different challenge and the implementation will depend on the used solution.
For the case of MongoDB, you can have a look at the
[MongoDB Replicaset Recipe](../../utils/mongo-replicaset/readme.md).
So, this recipes will show you how to connect to some backends, but how you
manage them is up to you.

Moreover, we will be discussing the deployment of the agent as a single
configurable entity. But note that within an agent, there exist multiple
available configurations (using single and multiple sources, channels and
sinks), as described in
[Advanced Cygnus Architectures](http://fiware-cygnus.readthedocs.io/en/latest/architecture/index.html#advanced-cygnus-architectures).
How you setup those internal advanced architectures and the advantages of each
will not be covered here, since this is already discussed in the official
documentation.

That being said, in order to deploy Cygnus, we need to understand whether it's
a stateless or stateful service. It turns out that source and sink parts of the
agent do not persist data, however, the channels do, at least for a short period
of time until data is processed and taken out of the channel by the sink[s]. As
you can read from Cygnus and Flume's documentation, channels come in the form of
MemoryChannel and FileChannel.

It's easy to see that MemoryChannel and Batching has a potential for data loss,
for example, in the case when an agent crashes before events were taken out of
the channel. In fact, to avoid storage access for each event, Cygnus comes with
default values of batch size and batch flush timeouts. As a side note, it'd be
nice if this could be dynamically changed according to dynamic demands, but this
is an interesting point to investigate at a later point.

Therefore, the FileChannel could be used, at the cost of a higher latency, to
give persistence to the "inflight data" and this way prevent a complete loss
if there happens to be a software failure/crash at the agent. Note however that
the location of this file within the container and not customizable, hence
a container crash will cause those un-flushed values to be lost.

One could explore ways to persist those channels somewhere else, or share
channels across different containers. Or maybe looking for Message-based
solutions such as Solace to be used at the Channel level. But this of course,
would involve some updates to Cygnus which are beyond the scope of this project.
