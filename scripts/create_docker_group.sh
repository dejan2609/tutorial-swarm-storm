#!/bin/bash

groupadd docker
usermod -aG docker $(whoami)
