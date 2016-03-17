# Tutorial: Deploying Apache Storm with Docker Swarm


## TL; DR

For those of you who want to see some results before diving into Swarm, here are the fast-forward instructions:

1. **Create server machines**: Spin up 3 Ubuntu 14.04 machines for our Docker Swarm Cluster; let's call them `Ubuntu 1`, `Ubuntu 2` and  `Ubuntu 3`.
2. **Connect to manager node**: Connect to `Ubuntu 1` via SSH. (This will be the Swarm Manager node.)
3.  **Configure and install Docker**: Now install git, check out our tutorial from GitHub and invoke the script that installs Docker:

        sudo apt-get install git -y && \
        git clone https://github.com/Baqend/tutorial-swarm-storm.git && \
        bash tutorial-swarm-storm/files/prepare.sh && \
        sudo reboot
*Optional*: If you want Swarm to use an already-existing ZooKeeper deployment, you can provide a single IP or a comma-separated list of IPs as an argument to the `bash files/prepare.sh` call. By default, our script will spawn a ZooKeeper Docker container to use for Coordination.
4. **Remember the IP**: When done, the script prints your IP in vivid green (e.g. `SWARM_ZOOKEEPER=10.10.100.26`) -- remember it!
5. **Set up Swarm cluster**: After reboot, log in via SSH again, and the tutorial directory and invoke the Swarm manager script:

        cd tutorial-swarm-storm/ && . files/setupManager.sh
6. **Set up workers**: You now have a running Cluster with a Single Worker Node on `Ubuntu 1`. To add more nodes to the Cluster, do the following:
	1. Almost like above, you have to configure and install Docker on `Ubuntu 2` and  `Ubuntu 3`. However, this time you *have to* provide the `prepare.sh` script with information on the ZooKeeper cluster used for coordination, for example like this:

            sudo apt-get install git -y && \
            git clone https://github.com/Baqend/tutorial-swarm-storm.git && \
            bash tutorial-swarm-storm/files/prepare.sh 10.10.100.26 && \
            sudo reboot
	2. After reboot, log in via SSH again, and the tutorial directory and invoke the Swarm *worker* script:

            cd tutorial-swarm-storm/ && . files/setupWorker.sh




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



