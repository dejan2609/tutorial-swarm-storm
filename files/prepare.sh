#!/bin/bash

#####################
# Export Parameters #
#####################

if [ $# -eq 0 ] || [ -z "$1" ]
then
    # no arguments were supplied, so ask for ZooKeeper server IPs:
    read -p "Please provide ZooKeeper server IPs like \"1.2.3.4\" or \"1.2.3.4,5.6.7.8\"!" zk
else
    zk=$1
fi

# the ZooKeeper cluster that can be used for Docker Swarm coordination has to be provided as first argument of the script.
# It can either be a single IP address such as
#    1.2.3.4
# or a comma-separated list of IP addresses (no white spaces!) such as
#    1.2.3.4,5.6.7.8
# For this tutorial, we'll just spin up a ZooKeeper Docker container on the Docker Swarm manager node. In production, you'll certainly want to add more nodes to the cluster (e.g. on the Docker Swarm worker nodes) or use an existing fault-tolerant ZooKeeper ensemble.
export ZOOKEEPER_SERVERS=$zk

# find the IP address of the machine that is executing this code:
export PRIVATE_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')


# append configuration to .bash_profile:
cat >> ~/.bash_profile << EOL
export ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS
export PRIVATE_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
EOL

# set up a repository and install latest docker version as described here:
# https://docs.docker.com/engine/installation/linux/ubuntulinux/
sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates && sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list
sudo apt-get update && sudo apt-get purge lxc-docker && sudo apt-cache policy docker-engine
sudo apt-get update -y && sudo  apt-get install -y linux-image-extra-$(uname -r) apparmor docker-engine git make
# create docker user group and add the current user, so that the current user can call the docker client
sudo usermod -aG docker $(whoami)
# Stop docker deamon
sudo service docker stop
# delete the key file that is used by Docker to identify each Docker Swarm worker (you may take a snapshot as long as the key file is deleted and you haven't restarted the service):
sudo rm /etc/docker/key.json

echo ""
echo "Your IP is: $PRIVATE_IP"
