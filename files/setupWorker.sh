#!/usr/bin/env bash

# install docker
. files/prepare.sh "$@"

# default options for Docker Swarm:
echo "DOCKER_OPTS=\"-H tcp://$PRIVATE_IP:2375 -H unix:///var/run/docker.sock --cluster-advertise eth0:2375 --cluster-store zk://$ZOOKEEPER_SERVERS\"" | sudo tee /etc/default/docker
# now restart the service:
sudo service docker restart
echo "Now let's wait a few moments"
sleep 5
# now make this machine join the Docker Swarm cluster:
docker run -d --restart=always swarm join --advertise=$PRIVATE_IP:2375 zk://$ZOOKEEPER_SERVERS
