#!/usr/bin/env bash

#The first argument provided to the script is the number of supervisors to deploy:
export SUPERVISORS="$1"

# start Storm UI container
docker run \
    -d \
    --label cluster=storm \
    -e constraint:server==manager \
    -e STORM_ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS \
    --net stormnet \
    --restart=always \
    --name ui \
    -p 8080:8080 \
    baqend/storm ui \
      -c nimbus.host=nimbus
# start Storm Nimbus container
docker run \
    -d \
    --label cluster=storm \
    -e constraint:server==manager \
    -e STORM_ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS \
    --net stormnet \
    --restart=always \
    --name nimbus \
    -p 6627:6627 \
    baqend/storm nimbus \
      -c nimbus.host=nimbus
# start Storm Supervisor container; they don't have to be named and you can just spawn as many as you like :-)

if ! [[ $SUPERVISORS =~ ^[0-9]+ ]] ; then
   echo "no number was provided (\"$SUPERVISORS\"). Will proceed with 1 supervisor."
   SUPERVISORS=1
fi
for (( i=1; i <= $SUPERVISORS; i++ ))
do
    docker run \
        -d \
        --label cluster=storm \
        -e STORM_ZOOKEEPER_SERVERS=$ZOOKEEPER_SERVERS \
        --net stormnet \
        --restart=always \
        baqend/storm supervisor \
         -c nimbus.host=nimbus \
         -c supervisor.slots.ports=6700,6701,6702,6703
done
