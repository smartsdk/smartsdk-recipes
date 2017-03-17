"""
This script is used to setup and mantain a MongoDB replicase on a Docker Swarm.

It is intended to be used with the docker-compose.yml in the mongodb replica recipe.

IMPORTANT: There should not be more than one process running this script in the swarm.

HOW IT WORKS (Overview):
- Scans mongod instances in the swarm
- Picks an arbitrary instance to act as a replicaset primary
- Configures the replicaset on it
- Keeps on listening to changes in the original set of mongod instances
- Reconfigures replicaset if a change was perceived.

TODOS:
The script is full of room for improvements as you can see from the TODOs spread
in the code.

# TODO: Idempotency. If the node where this is running goes down, it will be
rescheduled to a different node. Instead of setting up a new replicaset it should
recognize the one already running.

# TODO: Add tests
"""
import docker
import logging
import os
import pymongo as pm
import time


def get_required_env_variables():
    REQUIRED_VARS = [
        'OVERLAY_NETWORK_NAME',
        'MONGO_SERVICE_NAME',
        'REPLICASET_NAME',
        'MONGO_PORT'
    ]
    envs = {}
    for rv in REQUIRED_VARS:
        envs[rv.lower()] = os.environ[rv]

    if not all(envs.values()):
        raise RuntimeError("Missing required ENV variables. {}".format(envs))

    envs['mongo_port'] = int(envs['mongo_port'])
    return envs


def get_mongo_service(dc, mongo_service_name):
    for s in dc.services.list():
        if s.name == mongo_service_name:
            return s
    msg = "Error: Could not find mongo service with name {}. \
           Did you correctly deploy the stack with both services?.\
          ".format(mongo_service_name)
    logger = logging.getLogger(__name__)
    logger.error(msg, exc_info=True)
    return


def get_tasks_ips(tasks, overlay_network_name):
    tasks_ips = []
    for t in tasks:
        for n in t['NetworksAttachments']:
            if n['Network']['Spec']['Name'] == overlay_network_name:
                ip = n['Addresses'][0].split('/')[0]  # clean prefix from ip
                tasks_ips.append(ip)
    return tasks_ips


def create_mongo_config(tasks_ips, replicaset_name, mongo_port):
    members = []
    for i, ip in enumerate(tasks_ips):
        members.append({
          '_id': i,
          'host': "{}:{}".format(ip, mongo_port)
        })
    config = {
        '_id': replicaset_name,
        'members': members,
        'version': 1
    }
    return config


def configure_replica(mongo_service, overlay_network_name, replicaset_name, mongo_port):
    logger = logging.getLogger(__name__)

    # TODO: add healthchecks with retries in docker-compose, here or both as required
    # so as to remove this arbitrary sleep
    logger.info('Waiting some time before starting')
    time.sleep(142)

    # Get mongo tasks
    mongo_tasks = mongo_service.tasks()
    if len(mongo_tasks) == 0:
        msg = "Error: No task found for Mongo service. Missing a 'wait' time or healthcheck maybe?."
        logger.error(msg, exc_info=True)
        return

    # Prepare mongo config
    mongo_tasks_ips = get_tasks_ips(mongo_tasks, overlay_network_name)
    config = create_mongo_config(mongo_tasks_ips, replicaset_name, mongo_port)
    logger.info("Initial config: {}".format(config))

    # Choose a primary and configure replicaset
    primary_ip = mongo_tasks_ips[0]
    primary = pm.MongoClient(primary_ip, mongo_port)
    res = primary.admin.command("replSetInitiate", config)
    logger.info("replSetInitiate: {}".format(res))

    # Respond to changes
    current_ips = set(mongo_tasks_ips)
    while True:
        # TODO: Reacting to events is better than sleeping and polling
        time.sleep(42)

        new_ips = set(get_tasks_ips(mongo_service.tasks(), overlay_network_name))
        if not new_ips.difference(current_ips):
            continue
        else:
            # Actually not too different from what mongo does:
            # https://github.com/mongodb/mongo/blob/master/src/mongo/shell/utils.js
            to_remove = set(current_ips) - set(new_ips)
            to_add = set(new_ips) - set(current_ips)
            assert to_remove or to_add

            if to_remove:
                # Note: As of writing, when a node goes down with a task running
                # a global service, Swarm is not tearing down that task and hence
                # this removal part has not been fully tested.
                logger.info("To remove: {}".format(to_remove))
                new_members = [m for m in config['members'] if m['host'].split(":")[0] in to_remove]
                config['members'] = new_members

            if to_add:
                logger.info("To add: {}".format(to_add))
                offset = max([m['_id'] for m in config['members']]) + 1
                for i, ip in enumerate(to_add):
                    config['members'].append({
                      '_id': offset + i,
                      'host': "{}:{}".format(ip, mongo_port)
                    })

            if primary_ip in to_remove:
                # Find out who is the new primary and connect to it.
                # Solving this will solve the "Idempotency" of the script.
                # primary_ip = ?
                # primary = pm.MongoClient(primary_ip, MONGO_PORT)
                raise NotImplementedError("TODO: Primary failure recovery")

            # Apply new config
            config['version'] += 1
            logger.info("New config: {}".format(config))
            res = primary.admin.command("replSetReconfig", config)
            logger.info("replSetReconfig: {}".format(res))

            current_ips = new_ips


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    envs = get_required_env_variables()
    dc = docker.from_env()

    mongo_service = get_mongo_service(dc, envs.pop('mongo_service_name'))
    if mongo_service:
        configure_replica(mongo_service, **envs)
