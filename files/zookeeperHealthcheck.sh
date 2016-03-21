#!/usr/bin/env bash

docker exec -it zk$ZOOKEEPER_ID /opt/zookeeper/bin/zkServer.sh status
