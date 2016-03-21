#!/usr/bin/env bash

# Setup ZooKeeper
. files/setupZooKeeper.sh

# Wait for a majority of the ZooKeeper ensemble before proceeding with installation
MODE=
while [ -z $MODE ]
do
    echo "waiting for ZooKeeper ensemble to become healthy..."
    sleep 1
    MODE=$(. files/zookeeperHealthcheck.sh | grep ^Mode: | awk '{print $2;}')
done
echo "ZooKeeper ensemble up and running! This node is $MODE"


# the first server in the ZooKeeper server list is the Swarm managing node  --> all others are pure workers
if [ $ZOOKEEPER_ID == "1" ]
then
    . files/setupManager.sh
else
    . files/setupWorker.sh
fi
