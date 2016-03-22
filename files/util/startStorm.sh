#!/usr/bin/env bash

#The first argument provided to the script is the number of supervisors to deploy:
export SUPERVISORS="$1"

# create storm config file: files/stormhome/conf/storm.yaml
read -r -d '' STORM_CONFIG <<'EOF'
nimbus.host: "nimbus"

supervisor.slots.ports:
- 6700
- 6701
- 6702
- 6703

storm.zookeeper.servers:
EOF
# add all Zookeeper servers:
for index in "${!ZOOKEEPER_SERVERS_ARRAY[@]}"
do
    ZKID=$(($index+1))
    STORM_CONFIG="$STORM_CONFIG"$'\n'"- \"zk$ZKID\""
done
# write config file:
mkdir -p files/stormhome/conf
echo "$STORM_CONFIG" | tee files/stormhome/conf/storm.yaml


# start Storm UI container
docker run \
    -d \
    --label cluster=storm \
    -e constraint:server==manager \
    --net stormnet \
    --restart=always \
    --name ui \
    -p 8080:8080 \
    -v $(readlink -m files/stormhome):/mnt/storm \
    baqend/storm ui
# start Storm Nimbus container
docker run \
    -d \
    --label cluster=storm \
    -e constraint:server==manager \
    --net stormnet \
    --restart=always \
    --name nimbus \
    -p 6627:6627 \
    -v $(readlink -m files/stormhome):/mnt/storm \
    baqend/storm nimbus
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
        --net stormnet \
        --restart=always \
        -v $(readlink -m files/stormhome):/mnt/storm \
        baqend/storm supervisor
done
