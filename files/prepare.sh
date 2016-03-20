#!/usr/bin/env bash

# install Docker:
. files/installDocker.sh

# have the parameters sourced on every login:
cat << EOF | tee -a ~/.bash_profile
# source parameters:
. $(readlink -m files/config.sh) $@
EOF

# reboot to apply changes
sudo reboot
