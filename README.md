# BPMspaceCloud

## DockerHosts Initial Setup

### Prerequisites
Linux server with DEBIAN 9 (Stretch) and ssh access and named:
- docker_master_001.bpmspace.net
- docker_node_001.bpmspace.net
- docker_node_002.bpmspace.net

### ssh to docker_master_001 - login as root 
>wget https://raw.githubusercontent.com/BPMspaceUG/BPMspaceCloud/master/bpmspace_setup_dockerhost_stretch.sh
>chmod +x bpmspace_setup_dockerhost_stretch.sh
>./bpmspace_setup_dockerhost_stretch.sh MASTER docker_master_001.bpmspace.net

### ssh to docker_node_001 (WORKER) - login as root
>wget https://raw.githubusercontent.com/BPMspaceUG/BPMspaceCloud/master/bpmspace_setup_dockerhost_stretch.sh
>chmod +x bpmspace_setup_dockerhost_stretch.sh
>./bpmspace_setup_dockerhost_stretch.sh WORKER docker_node_001.bpmspace.net

### ssh to docker_node_002 (WORKER) - login as root
>wget https://raw.githubusercontent.com/BPMspaceUG/BPMspaceCloud/master/bpmspace_setup_dockerhost_stretch.sh
>chmod +x bpmspace_setup_dockerhost_stretch.sh
>./bpmspace_setup_dockerhost_stretch.sh WORKER docker_node_002.bpmspace.net


## ClusterFS Initial Setup 
### STEP I - ssh to docker_node_001 AND docker_node_002 - login as rootmessages

* [using glusterfs docker swarm cluster](http://embaby.com/blog/using-glusterfs-docker-swarm-cluster/)  
* [setup a 3 node replicated storage volume with glusterfs](https://blog.ruanbekker.com/blog/2019/03/05/setup-a-3-node-replicated-storage-volume-with-glusterfs/?referral=github.com)
* [setup 3 node high-availability-cluster with glusterfs and docker swarm](https://medium.com/running-a-software-factory/setup-3-node-high-availability-cluster-with-glusterfs-and-docker-swarm-b4ff80c6b5c3)

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) Setup only a 2 Node GlusterFS on the 2 Swarm Nodes (workers)

	1) sudo su root
	2) lsblk
	3) mkfs.xfs /dev/sdX
	4) systemctl start glusterfs-server
	5) mkdir /gluster/
	6) mkdir /gluster/bricks/
	7) mkdir /gluster/bricks/node_00Y
	8) echo '/dev/sdX /gluster/bricks/node_00Y xfs defaults 0 0' >> /etc/fstab
	9) mount -a
	10) mkdir /gluster/bricks/node_00Y/brick
	11) df -h
	12) sudo systemctl enable glusterfs-server
	14) reboot

### STEP II - ssh to docker_node_001
	1) sudo gluster peer probe <IP@-NODE002>
		Reply: peer probe: success.
	2) sudo gluster pool list
		Reply:
			UUID                                    Hostname        State
			ff972510-2b65-4b4f-b06c-9b87abc78d90    <IP@-NODE002>   Connected
			10b30a17-718b-4d92-bf04-9b8720085dd2    localhost       Connected
	3) sudo gluster volume create gluster_fs_nodes \
		replica 2 \
		<IP@-NODE001>:/gluster/bricks/node_001/brick \
		<IP@-NODE002>:/gluster/bricks/node_002/brick
		Reply:
		volume create: gluster_fs_nodes: success: please start the volume to access data
	4) sudo gluster volume start gluster_fs_nodes
		Reply: volume start: gluster_fs_nodes: success
	5) sudo gluster volume status gluster_fs_nodes
	6) sudo gluster volume set gluster_fs_nodes auth.allow <IP@-NODE001>,<IP@-NODE002>
	
### STEP III - ssh to docker_node_001 AND docker_node_002 - login as rootmessages
	1) sudo su root
	2) mkdir /mnt/gluster/ -p
	3) mkdir /mnt/gluster/gluster_fs_nodes -p
	4) echo 'localhost:/gluster_fs_nodes /mnt/gluster/gluster_fs_nodes glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab
	5) mount -a
	6) df -h

## DockerSwarm Initial Setup

BPMspaceCloud DockerSwarm is based on the Imixs-Cloud - https://github.com/imixs/imixs-cloud

_Imixs-Cloud_ is an open infrastructure project, providing a lightweight [docker](https://www.docker.com/) based container environment for production business applications. The main objectives of this project are **simplicity**, **transparency** and **operational readiness**. 
The _Imixs-Cloud_ is based on a [docker swarm](https://docs.docker.com/engine/swarm/) cluster environment.
Docker swarm is much easier to setup and in its management compared to a Kubernetes cluster. However, when deciding which platform  to use, you should consider your own criterias. _Imixs-Cloud_ is optimized to **build**, **run** and **maintain** business services in small and medium-sized enterprises.

### STEP I - ssh to docker_master_001 - login as rootmessages
	1) sudo rm /root/bpmspace_setup_dockerhost_stretch.sh 
	2) cd /home/rootmessages
	3) chmod +x ./BPMspaceCloud/dockerswarm/scripts/bpmspace_initiate_dockerswarm.sh
	4) sudo ./BPMspaceCloud/dockerswarm/scripts/bpmspace_initiate_dockerswarm.sh <IP@-MASTER>
	
### STEP II - ssh to docker_node_001 AND docker_node_002 - login as rootmessages
	1) sudo rm /root/bpmspace_setup_dockerhost_stretch.sh
	2) docker swarm join --token <TOKEN FROM STEP I-4>  <IP@-MASTER>:2377
	
### STEP III - ssh to docker_master_001 - login as rootmessages
	1)TEST network
		docker network ls | grep overlay
		Output should look like
			NETWORK ID	NAME		DRIVER		SCOPE
			1q17asdn5z6r	cloud-net	overlay		swarm
			sadfq830v4fb	ingress		overlay		swarm
			dzptc459kk30	proxy-net	overlay		swarm
	2) TEST Swarm 
		docker node ls
		Output should look like
			ID				HOSTNAME			STATUS	AVAILABILITY	MANAGER STATUS	ENGINE VERSION
			5ufqco634dq43usqulgnfvkb *	docker_master_001.bpmspace.net	Ready	Active		Leader		19.03.5
			vmk88y5o17q654b6az8l9p8x	docker_node_001.bpmspace.net	Ready	Active				19.03.5
			in0o2qh9iv8342ggzxcxiw15	docker_node_002.bpmspace.net	Ready	Active				19.03.5
	3) echo -n password | docker secret create portainer-admin-pass -
		(see https://github.com/portainer/portainer/issues/2816)
	4) sudo docker stack deploy -c ./BPMspaceCloud/dockerswarm/management/portainer/docker-compose.yml Portainer
	5) DOCKER SECRET NOT WORKING AT THE MOMENT WITH PORTAINER - so set passwd for user admin after the first start

### STEP IV - setup Portainer in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `NOTE:`The Stack "Portainer" has do be added a second time. Only then portainer can be fully controlde by Portainer.

> Name:	Portainer  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/management/portainer/  
	
![Portainer](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_Portainer.png "Portainer")

### STEP V - setup TraefikReverseProxy in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

> Name:	TraefikReverseProxy  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/management/traefik/  
> or via ssh sudo docker stack deploy -c BPMspaceCloud/dockerswarm/management/traefik/docker-compose.yml TraefikReverseProxy  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://traefik.bpmspace.net/dashboard/#/  

![TraefikReverseProxy](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_TraefikReverseProxy.png "TraefikReverseProxy")  
> INFO https://teqqy.de/traefik-dashboard-konfigurieren/

### STEP VI - setup WHOIS && Test in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

> Name:	Test_Whois  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/whoami/  
> or via ssh sudo docker stack deploy -c BPMspaceCloud/dockerswarm/apps/test/whoami/docker-compose.yml Test_Whois  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_whoami.bpmspace.net/  

### STEP VII - setup TEST_mariadb-mysql-phpmyadmin && Test in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `NOTE:`Check Volumes First!

![SETUP Volumes](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_VOLUMES_mariadb-mysql-phpmyadmin_TEST.png "SETUP Volumes")


> Name:	TEST_mariadb-mysql-phpmyadmin  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/mariadb-mysql-phpmyadmin/  
> or via ssh  sudo docker stack deploy -c BPMspaceCloud/dockerswarm/apps/test/mariadb-mysql-phpmyadmin/docker-compose.yml TEST_mariadb-mysql-phpmyadmin  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_phpmyadmin_mariadb10.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_phpmyadmin_mysql5.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_phpmyadmin_mysql8.bpmspace.net/  

### STEP VIII - setup shell2http && Test in [Portainer Management Console](https:/portainer.bpmspace.net:8880)
> Name:	shell2http  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/shell2http/  
> or via ssh  sudo docker stack deploy -c BPMspaceCloud/dockerswarm/apps/shell2http/docker-compose.yml shell2http  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://shell2http_swarm_master.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://shell2http_swarm_master.bpmspace.net/form?from=10&to=76987  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://shell2http_swarm_node.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://shell2http_swarm_node.bpmspace.net/form?from=10&to=76987  

### STEP Ix - setup shell2http && Test in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

> sudo mkdir -p /mnt/gluster/gluster_fs_nodes/TEST_nginx-glusterfs on docker_node_001 or docker_node_002  
  
> Name:	TEST_nginx-glusterfs  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/TEST_nginx-glusterfs/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_nginx-glusterfs.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST BASH: for ((n=0;n<1000000;n++)); do curl test_nginx-glusterfs.bpmspace.net; echo; done