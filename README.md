# Whalenado: A Tutorial on Deploying Apache Storm with Docker Swarm

For our upcoming **query caching and continuous query** features, we rely on [Apache Storm](http://storm.apache.org/) for low-latency data processing. Several projects have dedicated themselves to enabling multi-server Storm deployments on top of Docker (e.g. [wurstmeister/storm-docker](https://github.com/wurstmeister/storm-docker) or [viki-org/storm-docker](https://github.com/viki-org/storm-docker)), but scaling beyond server-limits always seems to make things complicated. Since scalability and ease-of-operation is key for our deployment, we have adopted Docker Swarm from the beginning and are very happy with how smoothly everything is humming along. With this tutorial, we'd like to share our experiences, raise your interest in **Baqend Real-Time API** we'll be releasing soon and ultimately increase the hype for Docker Swarm (because it is just awesome!) :-)

Both the tutorial with all resources and the Docker image we use to deploy Storm in production are available under the very permissive *Chicken Dance License v0.2*:

- **baqend/storm Docker image** at [Docker Hub](https://hub.docker.com/r/baqend/storm/) and [GitHub](https://github.com/Baqend/docker-storm)
- **tutorial with scripts etc.** at [GitHub](https://github.com/Baqend/tutorial-swarm-storm)
 
## What we are going to do

### Outline

We will start by describing the components of our tutorial deployment and explain how everything will be working together. After that, we'll directly get to the meat and bones of this tutorial and provide a step-by-step guide on how to deploy your very Docker Swarm cluster and a multi-node Apache Storm cluster on top. We will also cover some routine tasks like checking cluster health or listing containers (Docker) and remote topology deployment (Storm) in the process. But you do not have to copy-paste all commands from this tutorial into the shell: We have prepaired a [GitHub repository](https://github.com/Baqend/tutorial-swarm-storm) with bash scripts for all this.  
Finally, we will briefly point out some issues that are ignored in this tutorial for the sake of simplicity, but have to be addressed in production.


### Overview:  Deployment

The illustration below shows our tutorial deployment:

![An overview of our tutorial deployment.](overview.PNG)

We will

First, we install Docker as described here [install Docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/)

## Setting up Docker Swarm
### Preparation







## TL; DR

If you are of the impatient kind or just want to see some results before diving into Swarm, we prepared some fast-forward instructions:

1. **Preparation**: Spin up 3 Ubuntu 14.04 machines for our Docker Swarm Cluster; let's call them `Ubuntu 1`, `Ubuntu 2` and  `Ubuntu 3`. 
2. **Setup Swarm Manager** on `Ubuntu 1`: 
 1.  **Configure and install Docker**: Connect to  `Ubuntu 1` via SSH and install git, check out our tutorial from GitHub and invoke the script that installs Docker:

            sudo apt-get install git -y && \
            git clone https://github.com/Baqend/tutorial-swarm-storm.git && \
            bash tutorial-swarm-storm/files/prepare.sh
If you want Swarm to use an already-existing ZooKeeper deployment, you can provide a single IP or a comma-separated list of IPs as an argument to the `bash files/prepare.sh` call. By default, our script will spawn a  ZooKeeper Docker container on `Ubuntu 1` for Swarm Coordination.
 2. **Remember the IP**: When done, the script prints your IP in vivid green (e.g. `SWARM_ZOOKEEPER=10.10.100.26`) -- remember it!
 3. **Set up Swarm cluster**: After reboot, log in via SSH again and invoke the Swarm manager script:

            . tutorial-swarm-storm/files/setupManager.sh
3. **Setup Swarm Workers**: You now have a running Cluster with a Single Worker Node on `Ubuntu 1`. To add more nodes to the Cluster, do the following:
	1. Similar to above, you have to configure and install Docker on `Ubuntu 2` and  `Ubuntu 3`. However, this time you *have to* provide the `prepare.sh` script with information on the ZooKeeper cluster used for coordination, for example like this:

            sudo apt-get install git -y && \
            git clone https://github.com/Baqend/tutorial-swarm-storm.git && \
            bash tutorial-swarm-storm/files/prepare.sh 10.10.100.26 && \
            sudo reboot
	2. After reboot, log in via SSH again, and invoke the Swarm *worker* script:

            . tutorial-swarm-storm/files/setupWorker.sh
4. **Start the Storm Cluster**: Log into the Swarm manager machine (`Ubuntu 1`) and call the Storm launcher script. You can specify the desired number of supervisors as argument to the script:

       . tutorial-swarm-storm/files/util/startStorm.sh 3
5. **Deploy a Topology**: 

## Limitations (a.k.a. "Why this is not production-ready")
In this tutorial, we demonstrate how easy it can be to get a distributed Storm cluster up and running using Docker. However, we did not consider a number of operational issues that are pivotal to availability, fault-tolerance and security, for example

- [Protecting the Docker daemon Socket with HTTPS](https://docs.docker.com/v1.5/articles/https/)
- [Using a DNS to managed ZooKeeper servers](): In this tutorial, we identified ZooKeeper servers by IP address. However, this implies that a failed server can only be replaced by another server with *the same IP*. This is definitely not a desirable dependency and therefore you should set up a DNS server and use DNS names to identify ZooKeeper servers in the config files.
- []()


## Further Reading
- [Build a Swarm cluster for production](https://docs.docker.com/swarm/install-manual/)



