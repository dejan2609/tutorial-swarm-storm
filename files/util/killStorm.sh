#!/usr/bin/env bash

# remove all containers with the right label:
docker rm -f $(docker ps -a --no-trunc --filter "label=cluster=storm" | grep -v 'CONTAINER' | awk '{print $1;}')