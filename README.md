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

## DockerSwarm Initial Setup

BPMspaceCloud DockerSwarm is based on the Imixs-Cloud - https://github.com/imixs/imixs-cloud

_Imixs-Cloud_ is an open infrastructure project, providing a lightweight [docker](https://www.docker.com/) based container environment for production business applications. The main objectives of this project are **simplicity**, **transparency** and **operational readiness**. 
The _Imixs-Cloud_ is based on a [docker swarm](https://docs.docker.com/engine/swarm/) cluster environment.
Docker swarm is much easier to setup and in its management compared to a Kubernetes cluster. However, when deciding which platform  to use, you should consider your own criterias. _Imixs-Cloud_ is optimized to **build**, **run** and **maintain** business services in small and medium-sized enterprises.

### STEP I - ssh to docker_master_001 - login as rootmessages
	1) sudo rm /root/bpmspace_setup_dockerhost_stretch.sh 
	2) cd /home/rootmessages
	3) chmod +x ./BPMspaceCloud/dockerswarm/scripts/bpmspace_initiate_dockerswarm.sh
	4) sudo ./BPMspaceCloud/dockerswarm/scripts/setup.sh <IP@-MASTER>
	
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
	4) sudo docker stack deploy -c ./imixs-cloud/management/portainer/docker-compose.yml Portainer
	5) DOCKER SECRET NOT WORKING AT THE MOMENT WITH PORTAINER - so set passwd for user admin after the first start

### STEP IV - setup Portainer in [Portainer Management Console](http:/bpmspace.net:8880)

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `NOTE:`The Stack "Portainer" has do be added a second time. Only then portainer can be fully controlde by Portainer.

> Name:	Portainer  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/management/portainer/  
	
![Portainer](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_Portainer.png "Portainer")

### STEP V - setup TraefikReverseProxy in [Portainer Management Console](http:/bpmspace.net:8880)

> Name:	TraefikReverseProxy  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/management/traefik/
> or via ssh sudo docker stack deploy -c BPMspaceCloud/dockerswarm/management/traefik/docker-compose.yml TraefikReverseProxy
> TEST http://traefik.bpmspace.net/dashboard/#/


![TraefikReverseProxy](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_STACK_TraefikReverseProxy.png "TraefikReverseProxy")

### STEP VI - setup WHOIS && Test in [Portainer Management Console](http:/bpmspace.net:8880)

> Name:	TEST_WHOIS  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/whoami/  
> or via ssh sudo docker stack deploy -c BPMspaceCloud/dockerswarm/apps/test/whoami/docker-compose.yml TEST_WHOIS
> TEST http://test_whoami.bpmspace.net/  




### STEP VII - setup TEST_mariadb-mysql-phpmyadmin && Test in [Portainer Management Console](http:/bpmspace.net:8880)

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `NOTE:`Check Volumes First!

![SETUP Volumes](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/PORTAINER_SETUP_VOLUMES_mariadb-mysql-phpmyadmin_TEST.png "SETUP Volumes")


> Name:	TEST_mariadb-mysql-phpmyadmin  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/mariadb-mysql-phpmyadmin/  
> or via ssh  sudo docker stack deploy -c BPMspaceCloud/dockerswarm/apps/test/mariadb-mysql-phpmyadmin/docker-compose.yml TEST_mariadb-mysql-phpmyadmin
> TEST http://test_phpmyadmin_mariadb10.bpmspace.net/  
> TEST http://test_phpmyadmin_mysql5.bpmspace.net/  
> TEST http://test_phpmyadmin_mysql8.bpmspace.net/  


> Name:	shell2http  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/shell2http/  
> or via ssh  sudo docker stack deploy -c BPMspaceCloud/dockerswarm/apps/shell2http/docker-compose.yml shell2http
> TEST http://shell2http_swarm_node.bpmspace.net/  
> TEST http://shell2http_swarm_node.bpmspace.net/  
