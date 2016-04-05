#!/bin/bash

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
      baqend/zookeeper zk1.openstack.baqend.com,zk2.openstack.baqend.com,zk3.openstack.baqend.com 1
docker -H tcp://zk2.openstack.baqend.com:2375 run -d --restart=always \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      --name zk2 \
      baqend/zookeeper zk1.openstack.baqend.com,zk2.openstack.baqend.com,zk3.openstack.baqend.com 2
docker -H tcp://zk3.openstack.baqend.com:2375 run -d --restart=always \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      --name zk3 \
      baqend/zookeeper zk1.openstack.baqend.com,zk2.openstack.baqend.com,zk3.openstack.baqend.com 3

# Wait for the ZooKeeper ensemble to become healthy before proceeding with installation
MODE=
while [ -z $MODE ]
do
    echo "waiting for ZooKeeper ensemble to become healthy..."
    sleep 1
    MODE=$(docker exec -it zk$ZOOKEEPER_ID /opt/zookeeper/bin/zkServer.sh status | grep ^Mode: | awk '{print $2;}')
done
echo "ZooKeeper ensemble up and running! This node is $MODE"

# launch the Swarm manager
docker run -d --restart=always \
      --label container=manager \
      -p 2376:2375 \
      -v /etc/docker:/etc/docker \
      swarm manage zk://zk1.openstack.baqend.com,zk2.openstack.baqend.com,zk3.openstack.baqend.com

# make sure the client talks to the right Docker daemon:
cat << EOF | tee -a ~/.bash_profile
    # this node is the master and therefore should be able to talk to the Swarm cluster:
    export DOCKER_HOST=tcp://127.0.0.1:2376
EOF
export DOCKER_HOST=tcp://127.0.0.1:2376

# restart the manager just to make sure:
docker restart $(docker ps -a --no-trunc --filter "label=container=manager" | grep -v 'CONTAINER' | awk '{print $1;}')

# Let's have a look at the Swarm cluster:
docker info

