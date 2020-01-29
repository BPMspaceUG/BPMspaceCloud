# BPMspaceCloud

### Prerequisites for MULTI Host Docker Swarm and GLuster
Linux server with DEBIAN 9 (Stretch) and ssh access and named:
- docker_master_001.bpmspace.net
- docker_node_001.bpmspace.net
- docker_node_002.bpmspace.net

### Prerequisites for SINGLE Host Docker Swarm without Gluster
Linux server with DEBIAN 9 (Stretch) and ssh access and named:
- devtest.bpmspace.net

## Initial Setup on each NODE - login as root
	1) apt update && apt upgrade 
	2) apt install -y git curl sudo
	3) 







## ClusterFS Initial Setup 
### STEP I - ssh to docker_master_001, docker_node_001 AND docker_node_002 - login as root

Note: NOT Needed for a SINGLE HOST Docker Swarm ! e.g. DEVTEST Environment  

* [using glusterfs docker swarm cluster](http://embaby.com/blog/using-glusterfs-docker-swarm-cluster/)  
* [setup a 3 node replicated storage volume with glusterfs](https://blog.ruanbekker.com/blog/2019/03/05/setup-a-3-node-replicated-storage-volume-with-glusterfs/?referral=github.com)
* [setup 3 node high-availability-cluster with glusterfs and docker swarm](https://medium.com/running-a-software-factory/setup-3-node-high-availability-cluster-with-glusterfs-and-docker-swarm-b4ff80c6b5c3)

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) Setup a 3 Node GlusterFS on the Swarm Master and 2 Swarm workers

	1) sudo su root  
	2) lsblk  
	3) apt install xfsprogs -y  
	4) mkfs.xfs /dev/sdX  
	5) apt install -y glusterfs-server  
	6) systemctl start glusterfs-server  
	5) mkdir /gluster/  
	6) mkdir /gluster/bricks/  
	7) mkdir /gluster/bricks/node_00Y  OR  
	   mkdir /gluster/bricks/master_00X  
	8) echo '/dev/sdX /gluster/bricks/node_00Y xfs defaults 0 0' >> /etc/fstab  OR  
	   echo '/dev/sdX /gluster/bricks/master_00X xfs defaults 0 0' >> /etc/fstab  OR  
	9) mount -a  
	10) mkdir /gluster/bricks/node_00Y/brick  OR  
	    mkdir /gluster/bricks/master_00X/brick  OR  
	11) df -h  
	12) sudo systemctl enable glusterfs-server  
	14) reboot  

	REPEAT for docker_node_001 AND docker_node_002  
	
### STEP II.A -for a Multi HOST Docker Swarm- ssh to docker_master_001 - login as root

	1) gluster peer probe <IP@NODE001>
	   gluster peer probe <IP@NODE002>
		Reply: peer probe: success.
	2) gluster pool list
		Reply:
			UUID                                    Hostname        State
			cd882312-1a34-5ed2-b06c-9b942f19bd90    <IP@NODE002>   Connected
			ff972510-2b65-4b4f-b06c-9b87abc78d90    <IP@NODE002>   Connected
			10b30a17-718b-4d92-bf04-6a8320085dd2    localhost       Connected
	3) gluster volume create gluster_bpmspacecloud \
		replica 3 \
		<IP@MASTER001>:/gluster/bricks/master_001/brick \
		<IP@NODE001>:/gluster/bricks/node_001/brick \
		<IP@NODE002>:/gluster/bricks/node_002/brick
		Reply:
		volume create: gluster_bpmspacecloud: success: please start the volume to access data
	5) gluster volume start gluster_bpmspacecloud
		Reply: volume start: gluster_bpmspacecloud: success
	6) gluster volume status gluster_bpmspacecloud
	7) gluster volume set gluster_bpmspacecloud auth.allow <IP@MASTER001>,<IP@NODE001>,<IP@NODE002>
	8) mkdir /mnt/gluster/ -p
	9) mkdir /mnt/gluster/gluster_bpmspacecloud -p
	10) echo 'localhost:/gluster_bpmspacecloud /mnt/gluster/gluster_bpmspacecloud glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab
	11) mount -a
	12) cd /mnt/gluster/gluster_bpmspacecloud/gluster_bpmspacecloud
	13) apt install git -y
	13) git clone https://github.com/BPMspaceUG/BPMspaceCloud.git
	
### STEP II.B -for a SINGLE HOST Cluster- ssh to devtest.bpmspace.net - login as root
	1) mkdir /mnt/gluster/ -p
	2) mkdir /mnt/gluster/gluster_bpmspacecloud -p
	2) mkdir /mnt/gluster/gluster_bpmspacecloud_nodes -p
	3) cd /mnt/gluster/gluster_bpmspacecloud
	4) apt install git -y
	5) git clone https://github.com/BPMspaceUG/BPMspaceCloud.git

### STEP III - ssh to docker_node_001 OR docker_node_002 - login as root
Note: NOT Needed for a SINGLE HOST Docker Swarm ! e.g. DEVTEST Environment  

	1) mkdir /gluster/bricks/node_00Y/brick2
	2) gluster volume create gluster_bpmspacecloud_nodes \
		replica 2 \
		<IP@NODE001>:/gluster/bricks/node_001/brick \
		<IP@NODE002>:/gluster/bricks/node_002/brick
	3) gluster volume start gluster_bpmspacecloud_nodes
	4) gluster volume set gluster_bpmspacecloud auth.allow <IP@NODE001>,<IP@NODE002>
	
### STEP IV - ssh to docker_node_001 AND docker_node_002 - login as root
Note: NOT Needed for a SINGLE HOST Docker Swarm ! e.g. DEVTEST Environment  

	1) sudo su root  
	2) mkdir /mnt/gluster/ -p  
	3) mkdir /mnt/gluster/gluster_bpmspacecloud -p  
	3) mkdir /mnt/gluster/gluster_bpmspacecloud_nodes -p  
	4) echo 'localhost:/gluster_bpmspacecloud /mnt/gluster/gluster_bpmspacecloud glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab  
	5) echo 'localhost:/gluster_bpmspacecloud_nodes /mnt/gluster/gluster_bpmspacecloud_nodes glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab  
	6) mount -a  
	7) df -h  

## DockerHosts Initial Setup
### ssh to docker_master_001 OR devtest.bpmspace.net - login as root 
>/gluster_bpmspacecloud/BPMspaceCloud/bpmspace_setup_dockerhost_stretch.sh MASTER docker_master_001.bpmspace.net  
OR  
>/gluster_bpmspacecloud/BPMspaceCloud/bpmspace_setup_dockerhost_stretch.sh MASTER devtest.bpmspace.net  

### ssh to docker_node_001 (WORKER) - login as root
Note: NOT Needed for a SINGLE HOST Docker Swarm ! e.g. DEVTEST Environment  
>/gluster_bpmspacecloud/BPMspaceCloud/bpmspace_setup_dockerhost_stretch.sh WORKER docker_node_001.bpmspace.net

### ssh to docker_node_002 (WORKER) - login as root
Note: NOT Needed for a SINGLE HOST Docker Swarm ! e.g. DEVTEST Environment  
>/gluster_bpmspacecloud/BPMspaceCloud/bpmspace_setup_dockerhost_stretch.sh WORKER docker_node_002.bpmspace.net

## DockerSwarm Initial Setup

BPMspaceCloud DockerSwarm is based on the Imixs-Cloud - https://github.com/imixs/imixs-cloud

_Imixs-Cloud_ is an open infrastructure project, providing a lightweight [docker](https://www.docker.com/) based container environment for production business applications. The main objectives of this project are **simplicity**, **transparency** and **operational readiness**. 
The _Imixs-Cloud_ is based on a [docker swarm](https://docs.docker.com/engine/swarm/) cluster environment.
Docker swarm is much easier to setup and in its management compared to a Kubernetes cluster. However, when deciding which platform  to use, you should consider your own criterias. _Imixs-Cloud_ is optimized to **build**, **run** and **maintain** business services in small and medium-sized enterprises.

### STEP I - ssh to docker_master_001 OR OR devtest.bpmspace.net - login as rootmessages

	sudo /gluster_bpmspacecloud/BPMspaceCloud/dockerswarm/scripts/bpmspace_initiate_dockerswarm.sh <IP@MASTER>
	OR
	sudo /gluster_bpmspacecloud/BPMspaceCloud/dockerswarm/scripts/bpmspace_initiate_dockerswarm.sh <IP@DEVTEST>
	
	
### STEP II - ssh to docker_node_001 AND docker_node_002 - login as rootmessages

	docker swarm join --token <TOKEN FROM STEP I-4>  <IP@MASTER>:2377
	
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
	3) sudo docker stack deploy -c /mnt/gluster/gluster_bpmspacecloud/BPMspaceCloud/dockerswarm/management/portainer/docker-compose.yml Portainer

### STEP IV  A - setup Portainer PROD in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

![Portainer](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_Portainer_initial_admin.png "Portainer Initial Admin")
  
![Portainer](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_Portainer_initial_endpoint.png "Portainer Initial Admin")
  
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `NOTE:`The Stack "Portainer" has do be added a second time. Only then portainer can be fully controlde by Portainer.

> Name:	Portainer  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/management/portainer/  
	
![Portainer](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_Portainer.png "Portainer")
  
### STEP IV  B - setup Portainer DEVTEST in [Portainer Management Console](https:/portainer.bpmspace.net:8880)  
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `NOTE: There will be only ONE Portainer INstance in PROD to manage both endpoints "PROD" and "DEVTEST""  
> prepare on devtest.bpmspace.net - login as rootmessages  
> sudo mkdir /etc/systemd/system/docker.service.d -p  
> sudo cp /mnt/gluster/gluster_bpmspacecloud/BPMspaceCloud/dockerhost/docker-api/startup_options.conf /etc/systemd/system/docker.service.d/  
> sudo systemctl daemon-reload && sudo systemctl restart docker.service  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST curl -X GET http://localhost:2376/images/json  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST FROM MASTER_001 - MUST FAIL because firewall is closed - curl -X GET http://<IP@DEVTEST>:2376/images/json  
> uncomment rule for #Docker-API and change from_ip -s to <IP@MASTER001>  
> sudo nano /opt/iptables.sh  
> ./opt/iptables.sh  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST FROM MASTER_001 - MUST SUCCEED because firewall is open - curl -X GET http://<IP@DEVTEST>:2376/images/json  


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

### STEP Ix - setup TEST_nginx-glusterfs && Test in [Portainer Management Console](https:/portainer.bpmspace.net:8880)

> sudo mkdir -p /mnt/gluster/gluster_bpmspacecloud/TEST_nginx-glusterfs on docker_node_001 or docker_node_002  
  
> Name:	TEST_nginx-glusterfs  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/TEST_nginx-glusterfs/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_nginx-glusterfs.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST BASH: for ((n=0;n<1000000;n++));do printf "\033c"; echo "+++++++"; for ((m=0;m<5;m++)); do curl test_nginx-glusterfs.bpmspace.net; echo "-----"; done; sleep 3; done