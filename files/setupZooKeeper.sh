#!/usr/bin/env bash

if [ -z $ZOOKEEPER_ID ]
then
    echo "Not part of the ZooKeeper ensemble!"
else
    echo "Will spawn ZooKeeper server with IP $PRIVATE_IP and ID $ZOOKEEPER_ID. The entire ensemble will have $ZOOKEEPER_CLUSTERSIZE members."
    # write the ZooKeeper config into a file ...
    echo "$ZOOKEEPER_CONFIG" | tee zookeeper.cfg
    # generate ZooKeeper ID file in the data directory:
    echo "$ZOOKEEPER_ID" | sudo tee /var/lib/zookeeper/myid
    # ... and start ZooKeeper container (for communication between docker VMs)
    docker run -d --restart=always \
      -p 2181:2181 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      -v $(readlink -m zookeeper.cfg):$WORKDIR/zookeeper.cfg  \
      jplock/zookeeper
fi
