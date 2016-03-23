# Whalenado: A Tutorial on Deploying Apache Storm with Docker Swarm

For our upcoming **query caching and continuous query** features, we rely on [Apache Storm](http://storm.apache.org/) for low-latency data processing. Several projects have dedicated themselves to enabling multi-server Storm deployments on top of Docker (e.g. [wurstmeister/storm-docker](https://github.com/wurstmeister/storm-docker) or [viki-org/storm-docker](https://github.com/viki-org/storm-docker)), but scaling beyond server-limits always seems to make things complicated. Since scalability and ease-of-operation is key for our deployment, we have adopted Docker Swarm from the beginning and are very happy with how smoothly everything is humming along. With this tutorial, we'd like to share our experiences, raise your interest in **Baqend Real-Time API** we'll be releasing soon and ultimately increase the hype for Docker Swarm (because it is just awesome!) :-)
 
## What we are going to do

### Outline

We will start by describing the components of our tutorial deployment and explain how everything will be working together. After that, we'll directly get to the meat and bones of this tutorial and provide a step-by-step guide on how to deploy your very Docker Swarm cluster and a multi-node Apache Storm cluster on top. We will also cover some routine tasks like checking cluster health or listing containers (Docker) and remote topology deployment (Storm) in the process. But you do not have to copy-paste all commands from this tutorial into the shell: We have prepaired a [GitHub repository](https://github.com/Baqend/tutorial-swarm-storm) with bash scripts for all this and will reference the corresponding script as we go along.  
Finally, we will briefly point out some issues that are ignored in this tutorial for the sake of simplicity, but have to be addressed in production and list some interesting reads.

### Overview: Deployment

The gist of what makes Docker Swarm so awesome is that it feels like using plain Docker 
The illustration below shows our tutorial deployment:

![An overview of our tutorial deployment.](overview.PNG)

We'll have 3 machines running Ubuntu Server 14.04, each of which will be running a Docker daemon with several containers inside. After the initial setup, will only talk to one of the machines, though and it will  just feel like having a plane Docker daemon

## Step-By-Step

### Preparations
First, spin up 3 Ubuntu Server 14.04 machines and look up their IP addresses. We'll just refer to them by `%IP1`, `%IP2` and `%IP3`, respectively.  
Then do the following *on each Ubuntu machine*:

1. Start by appending some config like the real values for `%IP1`, `%IP2` and `%IP3` and convenience `export` statements to `.bash_profile` to have them ready the next time you log in:

		cat << EOF | tee -a ~/.bash_profile
		# the IP addresses of all Swarm cluster machines, IP1 being the manager node
		export IP1=%IP1
		export IP2=%IP2
		export IP3=%IP3

		# find the IP address of the machine that is executing this code:
		export PRIVATE_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
		# all nodes in the ZooKeeper ensemble as comma-separated list
		export ZOOKEEPER_SERVERS=$IP1,$IP2,$IP3
		EOF
**Note:** You'll have to fill in! 
2. Then, [install Docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/):

		sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates && sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
		&& echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list \
		&& sudo apt-get update && sudo apt-get purge lxc-docker && sudo apt-cache policy docker-engine \
		&& sudo apt-get update -y && sudo  apt-get install -y linux-image-extra-$(uname -r) apparmor docker-engine git make

3. To be able to call the Docker client without `sudo`, add the current user to the Docker user group:

		sudo usermod -aG docker $(whoami)
**Note:** These changes won't affect the current session.
4. If you want to take a snapshot of this machine with a ready-to-go Docker installation, stop the docker daemon, delete the key file that Docker uses to identify each Docker Swarm worker (Docker will generate a new one on restart) and shut down the machine before taking the snapshot:

			sudo service docker stop \
			&& sudo rm /etc/docker/key.json \
			&& sudo shutdown -h now
If you want to install Docker manually on all machines, you can just reboot to apply user group changes, instead:

		sudo reboot
**Note:** If you don't remove the key file before taking the snapshot, all machines spawned from this image will have the same identifier and you'll have a broken Swarm cluster.  


### Create the Swarm cluster

Next, you will be setting up the Swarm cluster. To this end you'll connect to one of the Ubuntu servers, start a ZooKeeper server for Swarm coordination, a Swarm manager and a Swarm worker container.

1. Connect to `Ubuntu 1` via SSH.
2. Perform a quick health check. If Docker is installed correctly, the following will print a hello-world message:

		docker run hello-world
3. 

### Add worker nodes to the Swarm cluster


### Deploy the Storm cluster



### 
#### 


## TL; DR

As mentioned above, we have published some scripts on GitHub to ease this entire ordeal. So if you want some quick results, he are the fast-forward instructions:

1. **Preparation**: Spin up 3 Ubuntu 14.04 machines for our Docker Swarm Cluster; let's call them `Ubuntu 1`, `Ubuntu 2` and  `Ubuntu 3` with IP addresses `%IP1`, `%IP2` and `%IP3`, respectively. 
2. **Connect via SSH**: Connect to all 3 machines via SSH.
3. **Setup phase 1**: On every machine, install git, check out the repository, change director and call the `prepare.sh` script. You are only required to provide one single parameter, namely all servers that take part in ZooKeeper ensemble as a comma-separated list (`%IP1,%IP2,%IP3`):

		sudo apt-get install git -y && \
		git clone https://github.com/Baqend/tutorial-swarm-storm.git && \
		cd tutorial-swarm-storm && \
		. files/prepare.sh %IP1,%IP2,%IP3
The `prepare.sh` script will install docker, do some configuration and append some `export` statements to `~/.bash_profile` for convenience during the following installation steps. Finally, the script will reboot.
4. **Setup phase 2**: After reboot, reconnect to all 3 machines, enter the tutorial directory and call the `setup.sh` script:

		cd tutorial-swarm-storm && \
		. files/setup.sh
This script will launch a ZooKeeper node, have it join the ZooKeeper ensemble and then wait for the other ZooKeeper nodes. When the ZooKeeper ensemble is complete, the script proceeds with the installation: When executed on `Ubuntu 1`, it will setup the Swarm manager and a pure worker on node otherwise.
4. **Create an overlay network**: On the Swarm manager machine (`Ubuntu 1`), make sure you are in the `tutorial-swarm-storm` directory and call the `createNetwork.sh` script to create a network that spans all swarm nodes and have the running ZooKeeper containers join it:

       	. files/createNetwork.sh
4. **Start the Storm Cluster**: Again, on the Swarm manager make sure you are in the `tutorial-swarm-storm` directory and call the Storm launcher script. You can specify the desired number of supervisors as argument to the script:

       	. files/util/startStorm.sh 3
5. **Deploy a Topology**: 

       	. files/util/deploy-topology.sh

## Limitations (a.k.a. "Missing Features")
In this tutorial, we demonstrated how to get a distributed Storm cluster up and running on top of Docker. However, we did not consider a number of operational issues that are pivotal to availability, fault-tolerance and security. In order to make this production-ready, you should definitely look into the following: 

- **HTTPS between Swarm nodes**: In order to prevent the complexity of this tutorial to going through the roof, we let out how to [configure Docker Swarm for TLS](https://docs.docker.com/swarm/configure-tls/). However, it is definitely critical for security!
- **DNS for ZooKeeper**: When going production, we strongly recommend employing a DNS and using *hostnames instead of IP addresses* when setting up the ZooKeeper ensemble. Using IP addresses (as we do in this tutorial) implies that a failed ZooKeeper node can only be replaced by another node with *the same IP*. This is definitely not a desirable dependency! 


## Closing Remarks

Both the tutorial with all resources and the Docker image we use to deploy Storm in production are available under the very permissive *Chicken Dance License v0.2*:

- **baqend/storm Docker image** at [Docker Hub](https://hub.docker.com/r/baqend/storm/) and [GitHub](https://github.com/Baqend/docker-storm)
- **tutorial with scripts etc.** at [GitHub](https://github.com/Baqend/tutorial-swarm-storm)

Please feel free to fork us on GitHub or file a pull request if you have any suggestions for further improvement! 
 
We hope you enjoyed this tutorial and leave us some feedback in the comments section below!