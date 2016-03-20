#!/bin/bash

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

echo "Shutdown or reboot to apply user group changes!"
