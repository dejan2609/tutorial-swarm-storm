#!/bin/bash

# copy script files to /etc/
sudo cp scripts/* /etc/

# PullDocker images that are needed later
declare -a images=("swarm" "baqend/zookeeper" "baqend/storm")
## now loop through the above array
for i in "${images[@]}"; do
   sudo docker pull "$i"
done
