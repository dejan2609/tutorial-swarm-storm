#!/bin/bash
# Now copy config files
cp -a -rv /mnt/storm/. .

# append own hostname to config file
echo "storm.local.hostname: `hostname -i`" | tee -a conf/storm.yaml

exec bin/storm "$@"
