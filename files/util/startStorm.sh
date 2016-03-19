#!/usr/bin/env bash

export SUPERVISORS="$1"
STORM_VERSION=apache-storm-0.9.5

# Not supported, yet
ZOOKEEPERNODES=$2

# start ZooKeeper container
if ! [[ $ZOOKEEPERNODES =~ ^[0-9]+ ]] ; then
   echo "no number was provided (\"$ZOOKEEPERNODES\"). Will proceed with 1 ZooKeeper node."
   ZOOKEEPERNODES=1
fi
docker run \
    -d \
    --label cluster=storm \
    --net stormnet \
    --restart=always \
    --name zk1 \
    jplock/zookeeper

# start Storm UI container
docker run \
    -d  -it \
    -e constraint:server==manager \
    --net stormnet \
    --restart=always \
    --name ui \
    -p 8080:8080 \
    -e STORM_VERSION=$STORM_VERSION \
    -v /home/ubuntu/files:/mnt/storm \
    baqend/storm ui
# start Storm Nimbus container
docker run \
    -d \
    -e constraint:server==manager \
    --net stormnet \
    --restart=always \
    --name nimbus \
    -p 6627:6627 \
    -e STORM_VERSION=$STORM_VERSION \
    -v /home/ubuntu/files:/mnt/storm \
    baqend/storm nimbus
# start Storm Supervisor container; they don't have to be named and you can just spawn as many as you like :-)

if ! [[ $SUPERVISORS =~ ^[0-9]+ ]] ; then
   echo "no number was provided (\"$SUPERVISORS\"). Will proceed with 1 supervisor."
   SUPERVISORS=1
fi
for (( i=1; i <= $SUPERVISORS; i++ ))
do
    docker run \
        -d \
        --label cluster=storm \
        --net stormnet \
        --restart=always \
        -e STORM_VERSION=$STORM_VERSION \
        -v /home/ubuntu/files:/mnt/storm \
        baqend/storm supervisor
done
