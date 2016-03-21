#!/usr/bin/env bash

# create docker network spanning all VMs
docker network create --driver overlay stormnet
# show network info
docker network ls

# collect all ZooKeeper containers and add them to the Storm network
for index in "${!ZOOKEEPER_SERVERS_ARRAY[@]}"
do
    ZKID=$(($index+1))
    docker network connect stormnet zk$ZKID
done
