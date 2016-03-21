#!/usr/bin/env bash

# the first parameter has to be the ABSOLUTE path to the topology fatjar --> let's make it absolute!
JARFILE=$(readlink -m $1)

# the second argument is the remote nimbus's IP address or name
NIMBUS=$2

# All parameters from here on are for the topology (i.e. main class etc.)

# We will create a temporary storm.yaml file to pass the docker container
FILE=storm.yaml.temp.isonthisfileshouldhavebeendeletedsogoaheadanddeletedifyoufindit
# create temporary storm.yaml file
cat << EOF | tee $FILE
nimbus.host: "$NIMBUS"
nimbus.thrift.port: 6627
EOF

docker run \
   -it \
   --rm \
   -v $JARFILE:/topology.jar \
   -v $(readlink -m $FILE):/mnt/storm/conf/storm.yaml \
   baqend/storm \
   jar /topology.jar "${@:3}"

# remove temporary storm.yaml file
rm -f $FILE
