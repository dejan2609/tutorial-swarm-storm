# Tutorial: Deploying Apache Storm with Docker Swarm


## TL; DR

For those of you who want to see some results before diving into Swarm, here are the fast-forward instructions:

1. Spin up 3 Ubuntu 14.04 machines for our Docker Swarm Cluster; let's call them `Ubuntu 1`, `Ubuntu 2` and  `Ubuntu 3`.
2. Connect to `Ubuntu 1` via SSH. (This will be the Swarm Manager node.)
3. Find out the IP address of `Ubuntu 1` (and remember it for later):

        /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
4. Now install git, check out our tutorial from GitHub and change directory:

        sudo apt-get install git -y && \
        git clone https://github.com/Baqend/tutorial-swarm-storm.git && \
        cd tutorial-swarm-storm/
5. 

Our upcoming **query caching and continuous query** features heavily depend on the low-latency real-time data processing framework [Apache Storm](http://storm.apache.org/). 

Both the tutorial with all resources and the Docker image we use to deploy Storm in production are available under the very permissive *Chicken Dance License v0.2*:

- **baqend/storm Docker image**: [Docker Hub](https://hub.docker.com/r/baqend/storm/) and [GitHub](https://github.com/Baqend/docker-storm)
- **scripts etc.**: [the complete tutorial with scripts etc. at GitHub](https://github.com/Baqend/tutorial-swarm-storm)
 
## Overview

![An overview of our tutorial deployment.](overview.PNG)


First, we install Docker as described here [install Docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/)

## 


## Limitations
In this tutorial, we demonstrate how easy it can be to get a distributed Storm cluster up and running using Docker. However, we did not consider a number of operational  issues that are pivotal to availability, fault-tolerance and security, for example

- [Protecting the Docker daemon Socket with HTTPS](https://docs.docker.com/v1.5/articles/https/)
- [using a multi-node ZooKeeper ensemble]()
- []()


## Further Reading
- [Build a Swarm cluster for production](https://docs.docker.com/swarm/install-manual/)



