#!/usr/bin/env bash
docker restart $(docker ps -a --no-trunc --filter "label=container=manager" | grep -v 'CONTAINER' | awk '{print $1;}')