#!/bin/bash

# copy script files to /etc/
sudo cp scripts/{init.sh,killStorm.sh,restartManager.sh,storm.sh,swarm.sh} /etc/

# PullDocker images that are needed later
declare -a images=("swarm" "baqend/zookeeper" "baqend/storm")
for i in "${images[@]}"; do
   sudo docker pull "$i"
done
