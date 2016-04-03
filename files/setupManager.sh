#!/usr/bin/env bash

if [ $PRIVATE_IP == "10.10.100.26" ];then echo "yes"; else echo "no";fi


# default options for Docker Swarm:
echo "DOCKER_OPTS=\"-H tcp://$PRIVATE_IP:2375 \
    -H unix:///var/run/docker.sock \
    --label server=manager \
    --cluster-advertise eth0:2375 \
    --cluster-store zk://$ZOOKEEPER_SERVERS\"" \
| sudo tee /etc/default/docker

# restart the service to apply new options:
sudo service docker restart

# start docker swarm management container
docker run -d --label container=manager -p 2376:2375 --restart=always -v /etc/docker:/etc/docker swarm manage zk://$ZOOKEEPER_SERVERS
# now make this machine join the Docker Swarm cluster:
docker run -d --restart=always swarm join --advertise=$PRIVATE_IP:2375 zk://$ZOOKEEPER_SERVERS
# wait a few moments:
echo "Now let's wait a few moments for the worker to come up"
sleep 10

# only the master should be able to talk to the Swarm cluster:
cat << EOF | tee -a ~/.bash_profile

# this node is the master and therefore should be able to talk to the Swarm cluster:
export DOCKER_HOST=tcp://127.0.0.1:2376
EOF
export DOCKER_HOST=tcp://127.0.0.1:2376

# show swarm info:
docker info
# should look something like this:
#    Containers: 7
#      Running: 7
#      Paused: 0
#      Stopped: 0
#    Images: 6
#    Server Version: swarm/1.1.3
#    Role: primary
#    Strategy: spread
#    Filters: health, port, dependency, affinity, constraint
#    Nodes: 3
#      docker1: 10.10.100.26:2375
#       └ Status: Healthy
#       └ Containers: 3
#       └ Reserved CPUs: 0 / 1
#       └ Reserved Memory: 0 B / 2.053 GiB
#       └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-40-generic, operatingsystem=Ubuntu 14.04.1 LTS, server=manager, storagedriver=devicemapper
#       └ Error: (none)
#       └ UpdatedAt: 2016-03-20T22:22:22Z
#      docker2: 10.10.100.27:2375
#       └ Status: Healthy
#       └ Containers: 2
#       └ Reserved CPUs: 0 / 1
#       └ Reserved Memory: 0 B / 2.053 GiB
#       └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-40-generic, operatingsystem=Ubuntu 14.04.1 LTS, storagedriver=devicemapper
#       └ Error: (none)
#       └ UpdatedAt: 2016-03-20T22:21:48Z
#      docker3: 10.10.100.28:2375
#       └ Status: Healthy
#       └ Containers: 2
#       └ Reserved CPUs: 0 / 1
#       └ Reserved Memory: 0 B / 2.053 GiB
#       └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-40-generic, operatingsystem=Ubuntu 14.04.1 LTS, storagedriver=devicemapper
#       └ Error: (none)
#       └ UpdatedAt: 2016-03-20T22:22:33Z
#    Plugins:
#      Volume:
#      Network:
#    Kernel Version: 3.13.0-40-generic
#    Operating System: linux
#    Architecture: amd64
#    CPUs: 3
#    Total Memory: 6.159 GiB
#    Name: 542da9735bcd