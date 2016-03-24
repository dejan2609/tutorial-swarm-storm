#!/usr/bin/env bash

cat << EOF | tee -a ~/.bash_profile
# the servers in the ZooKeeper ensemble
export ZOOKEEPER_SERVERS=10.10.100.26,10.10.100.27,10.10.100.28
# the IP address of this machine:
export PRIVATE_IP=\$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}')
EOF


# install Docker:
. files/installDocker.sh

# have the parameters sourced on every login:
cat << EOF | tee -a ~/.bash_profile
# source parameters:
. $(readlink -m files/config.sh) $@
EOF

sudo sed -i -e "s/exit 0$/\/bin\/bash \/etc\/prepareWorker.sh\nexit 0/g" /etc/rc.local \
&& cat << EOF | sudo tee /etc/prepareWorker.sh
# the servers in the ZooKeeper ensemble
export ZOOKEEPER_SERVERS=10.10.100.26,10.10.100.27,10.10.100.28

# the IP address of this machine:
export PRIVATE_IP=\$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}')

# default options for Docker Swarm:
echo "DOCKER_OPTS=\"-H tcp://\$PRIVATE_IP:2375 \
    -H unix:///var/run/docker.sock \
    --cluster-advertise eth0:2375 \
    --cluster-store \
    zk://\$ZOOKEEPER_SERVERS\"" \
| sudo tee /etc/default/docker
# now restart the service to apply new options:
sudo service docker restart

# now make this machine join the Docker Swarm cluster:
docker run -d --restart=always swarm join --advertise=\$PRIVATE_IP:2375 zk://\$ZOOKEEPER_SERVERS

# finally comment out the script call in /etc/rc.local, so that it isn't executed again
sudo sed -i -e "s/\/bin\/bash \/etc\/prepareWorker.sh\n//g" /etc/rc.local
EOF

# shut down to take a snapshot
sudo shutdown -h now
