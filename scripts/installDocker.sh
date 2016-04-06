#!/bin/bash

apt-get update
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee -a /etc/apt/sources.list.d/docker.list
apt-get update && apt-get purge lxc-docker && apt-cache policy docker-engine
apt-get update -y &&  apt-get install -y linux-image-extra-$(uname -r) apparmor docker-engine git make


# stop the Docker service and remove the key file
service docker stop \
&& rm /etc/docker/key.json
