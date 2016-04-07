#!/bin/bash

# first script argument: the servers in the ZooKeeper ensemble:
ZOOKEEPER_SERVERS=$1

# everything looks alright so far?
docker ps

# launch the ZooKeeper ensemble:
# Put all ZooKeeper server IPs into an array:
IFS=', ' read -r -a ZOOKEEPER_SERVERS_ARRAY <<< "$ZOOKEEPER_SERVERS"
for index in "${!ZOOKEEPER_SERVERS_ARRAY[@]}"; do
    ZKID=$(($index+1))
    ZK=${ZOOKEEPER_SERVERS_ARRAY[index]}
    docker -H tcp://$ZK:2375 run -d --restart=always \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      -v /var/lib/zookeeper:/var/lib/zookeeper \
      -v /var/log/zookeeper:/var/log/zookeeper  \
      --name zk$ZKID \
      baqend/zookeeper $ZOOKEEPER_SERVERS $ZKID
done

echo "let's wait a little..."
sleep 30

# launch the Swarm manager
docker run -d --restart=always \
      --label container=manager \
      -p 2376:2375 \
      -v /etc/docker:/etc/docker \
      swarm manage zk://$ZOOKEEPER_SERVERS

echo "let's wait a little..."
sleep 30

# check ZooKeeper health:
for index in "${!ZOOKEEPER_SERVERS_ARRAY[@]}"; do
    ZKID=$(($index+1))
    ZK=zk$ZKID
    echo "checking $ZK:"
	docker exec -it $zk bin/zkServer.sh status
done


# check containers
docker ps

# make sure the client talks to the right Docker daemon:
cat << EOF | tee -a ~/.bash_profile
    # this node is the master and therefore should be able to talk to the Swarm cluster:
    export DOCKER_HOST=tcp://127.0.0.1:2376
EOF
export DOCKER_HOST=tcp://127.0.0.1:2376

# restart the manager just to make sure:
docker restart $(docker ps -a --no-trunc --filter "label=container=manager" | awk '{if(NR>1)print $1;}')

echo "let's wait a little..."
sleep 30


# Let's have a look at the Swarm cluster:
docker info
