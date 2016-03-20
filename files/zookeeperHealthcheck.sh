#!/usr/bin/env bash

docker exec zk$ZOOKEEPER_ID /opt/zookeeper/bin/zkServer.sh status
