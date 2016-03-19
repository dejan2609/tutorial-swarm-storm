#!/usr/bin/env bash

# default options for Docker Swarm:
echo "DOCKER_OPTS=\"-H tcp://$PRIVATE_IP:2375 -H unix:///var/run/docker.sock --cluster-advertise eth0:2375 --cluster-store zk://$ZOOKEEPER_SERVERS\"" | sudo tee /etc/default/docker
# now restart the service:
sudo service docker restart
echo "Now let's wait a few moments"
sleep 5

# write the ZooKeeper config into a file ...
echo "$ZOOKEEPER_CONFIG" | tee zookeeper.cfg
# ... and start ZooKeeper container (for communication between docker VMs)
docker run -d --restart=always \
   -p 2181:2181 \
  -v /var/lib/zookeeper:/var/lib/zookeeper \
  -v /var/log/zookeeper:/var/log/zookeeper  \
  -v $(readlink -m zookeeper.cfg):$WORKDIR/zookeeper.cfg  \
  jplock/zookeeper

# now make this machine join the Docker Swarm cluster:
docker run -d --restart=always swarm join --advertise=$PRIVATE_IP:2375 zk://$ZOOKEEPER_SERVERS
