"""
Setup a MongoDB replicase on a Docker Swarm.
"""
import docker
import pymongo as pm
import time

# TODO: Link to env variables in docker-compose.yml
STACK_NAME = 'mongo-replica'
OVERLAY_NETWORK_NAME = '{}_replica'.format(STACK_NAME)
SERVICE_NAME_MONGO = '{}_mongo'.format(STACK_NAME)
REPLICASET_NAME = 'rs'
MONGO_PORT = 27017

def configure_replica():
    dc = docker.from_env()

    # Get mongo tasks
    services = {s.name:s for s in dc.services.list()}
    if SERVICE_NAME_MONGO not in services:
        print("Could not find mongo service. Did you correctly deploy the stack with both services?.")
        return

    mongo_service = services[SERVICE_NAME_MONGO]
    mongo_tasks = mongo_service.tasks()
    if len(mongo_tasks) == 0:
        print("Error: No task found for Mongo service. Missing a 'wait' time maybe?.")
        return

    # Get overlay network IPS of running mongo daemons.
    mongo_tasks_ips = []
    for t in mongo_tasks:
        for n in t['NetworksAttachments']:
            if n['Network']['Spec']['Name'] == OVERLAY_NETWORK_NAME:
                # clean ip
                ip = n['Addresses'][0].split('/')[0]
                mongo_tasks_ips.append(ip)

    # Connect to one mongod
    master_ip = str(mongo_tasks_ips[0])
    master = pm.MongoClient(master_ip, MONGO_PORT)

    # Prepare mongo config
    members = []
    for i, ip in enumerate(mongo_tasks_ips):
        members.append({
          '_id': i,
          'host': "{}:{}".format(ip, MONGO_PORT)
        })
    config = {'_id': REPLICASET_NAME, 'members': members}
    print("Using config: {}".format(config))

    # Configure replica-set
    res = master.admin.command("replSetInitiate", config)
    print(res)

if __name__ == '__main__':
    configure_replica()
