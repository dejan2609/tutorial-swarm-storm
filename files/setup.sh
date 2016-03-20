#!/usr/bin/env bash

# the first server in the ZooKeeper server list is the Swarm managing node  --> all others are pure workers
if [ $ZOOKEEPER_ID == "1" ]
then
    . files/setupManager.sh
else
    . files/setupWorker.sh
fi
