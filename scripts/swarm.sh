#!/bin/bash

# first script argument: the servers in the ZooKeeper ensemble:
ZOOKEEPER_SERVERS=$1

# everything looks alright so far?
docker ps

# launch the ZooKeeper ensemble:
docker -H tcp://zk1.openstack.baqend.com:2375 run -d --restart=always \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      --name zk1 \
      baqend/zookeeper $ZOOKEEPER_SERVERS 1
docker -H tcp://zk2.openstack.baqend.com:2375 run -d --restart=always \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      --name zk2 \
      baqend/zookeeper $ZOOKEEPER_SERVERS 2
docker -H tcp://zk3.openstack.baqend.com:2375 run -d --restart=always \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      --name zk3 \
      baqend/zookeeper $ZOOKEEPER_SERVERS 3

# launch the Swarm manager
docker run -d --restart=always \
      --label container=manager \
      -p 2376:2375 \
      -v /etc/docker:/etc/docker \
      swarm manage zk://$ZOOKEEPER_SERVERS

# wait a little:
sleep 10

# check containers
docker ps

# make sure the client talks to the right Docker daemon:
cat << EOF | tee -a ~/.bash_profile
    # this node is the master and therefore should be able to talk to the Swarm cluster:
    export DOCKER_HOST=tcp://127.0.0.1:2376
EOF
export DOCKER_HOST=tcp://127.0.0.1:2376

# restart the manager just to make sure:
docker restart $(docker ps -a --no-trunc --filter "label=container=manager" | awk '{if(NR>1)print $1;}')

# wait a little:
sleep 10

# Let's have a look at the Swarm cluster:
docker info
