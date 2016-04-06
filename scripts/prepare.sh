#!/bin/bash

# copy script files to /etc/
sudo cp scripts/{init.sh,killStorm.sh,restartManager.sh,storm.sh,swarm.sh} /etc/

# PullDocker images that are needed later
declare -a images=("swarm" "baqend/zookeeper" "baqend/storm")
for i in "${images[@]}"; do
   sudo docker pull "$i"
done

# stop the Docker service and remove the key file
sudo service docker stop \
&& sudo rm /etc/docker/key.json
