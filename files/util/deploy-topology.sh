#!/usr/bin/env bash
# the first parameter has to be the ABSOLUTE path of the topology fatjar
JARFILE=$1
docker run \ 
# run interactively to see what is happening
   -it \ 
# remove container when done
   --rm \ 
# have container John storm net (REQUIRED???)
   --net stormnet \ 
# mount the jar file
   -v $JARFILE:/topology.jar \ 
# provide docker image name
   baqend/storm \ 
# tell storm to use all script arguments apart from the first one
   jar /topology.jar "${@:2}"
