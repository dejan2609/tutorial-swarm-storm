#!/bin/bash

# first script argument: the servers in the ZooKeeper ensemble:
ZOOKEEPER_SERVERS=$1

# second script argument: number of supervisors to launch
SUPERVISORS=$2
# if no valid number was given: just assume 1 as default
if ! [[ $SUPERVISORS =~ ^[0-9]+ ]] ; then
   echo "no number was provided (\"$SUPERVISORS\"). Will proceed with 1 supervisor."
   SUPERVISORS=1
fi

# create overlay network
docker network create --driver overlay stormnet

# check network
docker network ls

# launch nimbus
docker run \
    -d \
    --label cluster=storm \
    --label role=nimbus \
    -e constraint:server==manager \
    -e STORM_ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS \
    --net stormnet \
    --restart=always \
    --name nimbus \
    -p 6627:6627 \
    baqend/storm nimbus 

# launch UI
docker run \
    -d \
    --label cluster=storm \
    --label role=ui \
    -e constraint:server==manager \
    -e STORM_ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS \
    --net stormnet \
    --restart=always \
    --name ui \
    -p 8080:8080 \
    baqend/storm ui 

# launch the supervisors
for (( i=1; i <= $SUPERVISORS; i++ )); do
      docker run \
          -d \
          --label cluster=storm \
          --label role=supervisor \
          -e affinity:role!=supervisor \
          -e STORM_ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS \
          --net stormnet \
          --restart=always \
          baqend/storm supervisor 
done


# Let's have a look at the Swarm cluster:
docker info

# let's have a look at the containers
docker ps
