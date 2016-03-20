#!/usr/bin/env bash

# install Docker:
. files/installDocker.sh

# source parameters:
. files/config.sh "$@"
# have the parameters sourced on every login:
cat << EOF | tee -a ~/.bash_profile
# source parameters:
. $(readlink -m files/config.sh) $@
EOF

# default options for Docker Swarm:
echo "DOCKER_OPTS=\"-H tcp://$PRIVATE_IP:2375 \
    -H unix:///var/run/docker.sock \
    --label server=manager \
    --cluster-advertise eth0:2375 \
    --cluster-store zk://$ZOOKEEPER_SERVERS\"" \
| sudo tee /etc/default/docker
# now restart the service:
sudo service docker restart
echo "Now let's wait a few moments"
sleep 5

# set up ZooKeeper:
. files/setupZooKeeper.sh

# start docker swarm management container
sudo docker run -d --label container=manager -p 2376:2375 --restart=always -v /etc/docker:/etc/docker swarm manage zk://$ZOOKEEPER_SERVERS
# now make this machine join the Docker Swarm cluster:
sudo docker run -d --restart=always swarm join --advertise=$PRIVATE_IP:2375 zk://$ZOOKEEPER_SERVERS
# wait a few moments:
echo "Now let's wait a few moments for the worker to come up"
sleep 10

# create docker network spanning all VMs
sudo docker network create --driver overlay stormnet
# show swarm info:
sudo docker info
# show network info
sudo docker network ls

sudo reboot
