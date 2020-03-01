![BPMspace](https://github.com/BPMspaceUG/BPMspaceCloud/blob/master/_img/bpm-space-logo_600px.png "BPMspace Cloud")

# BPMspaceCloud

### Prerequisites for MULTI Host Docker Swarm and Gluster
Linux server with DEBIAN 9 (Stretch) and ssh access and named:
- docker-master-001.$DOCKERDOMAIN (e.g. for $MASTER001NAME)
- docker-node-001.$DOCKERDOMAIN(e.g. for $NODE001NAME)
- docker-node-002.$DOCKERDOMAIN(e.g. for $NODE002NAME)

## Initial Setup on each Cluster Member - login as root
	1) apt update -y && apt upgrade -y
	2) apt install -y git curl sudo
	3) git clone https://github.com/BPMspaceUG/BPMspaceCloud.git
	4) nano /root/BPMspaceCloud/bpmspace_step_01_setglobalvar.sh
	5) chmod u+x /root/BPMspaceCloud/*.sh
	6) /root/BPMspaceCloud/bpmspace_step_01_setglobalvar.sh
	7) for env in $( cat /etc/environment ); do export $(echo $env | sed -e 's/"//g'); done
	8) /root/BPMspaceCloud/bpmspace_step_02_checkglobalvar.sh
	9) reboot

## INSTALL & CONFIG on each Cluster Member - login as root
	1) /root/BPMspaceCloud/bpmspace_step_02_checkglobalvar.sh
	2) /root/BPMspaceCloud/bpmspace_step_03_install.sh

## ClusterFS Initial Setup - Multi HOST Docker Swarm 

### STEP I  - ssh to each Cluster Member  - login as rootmessages
	1) sudo su root  
	2) lsblk  
	4) mkfs.xfs /dev/sdX  
	5) /root/BPMspaceCloud/bpmspace_step_04_01_gluster.sh sdX
	
### STEP II -for a Multi HOST Docker Swarm - ssh ONLY on NODE_001 - login as rootmessages

	1) sudo su root
	2) /root/BPMspaceCloud/bpmspace_step_04_02_gluster.sh
	
### STEP III -for a Multi HOST Docker Swarm - ssh to each Cluster Member  - login as rootmessages

	1) sudo su root
	2) /root/BPMspaceCloud/bpmspace_step_04_03_gluster.sh

## Ansibel Initial Setup 

### step 1 - ssh to docker-master-001 - login as rootmessages

	1) sudo su root
	2) ssh-keygen -t rsa -b 4096 -C "rootmessages@"$DOCKERDOMAIN 
	3) mkdir /mnt/gluster/gluster_bpmspacecloud/tmp/
	4) cp .ssh/id_rsa.pub /mnt/gluster/gluster_bpmspacecloud/tmp/
	5) cat /etc/ansible/hosts

	
### step 2 - - ssh to each Cluster Member  - login as rootmessages

	1) cat /mnt/gluster/gluster_bpmspacecloud/tmp/id_rsa.pub >> /home/rootmessages./ssh/authorized_keys


### step 3 - ssh to docker-master-001 - login as rootmessages
	![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST 
	1) ssh  root@$MASTER001NAME
	2) ssh  root@$NODE001NAME
	3) ssh  root@$NODE002NAME
	4) cat /etc/ansible/hosts
	5) ansible -u rootmessages -m command -a "df -h" SwarmMember 
	6) ansible -u rootmessages -m command -a "df -h" SwarmNode
	7) ansible -u rootmessages -m command -a "arch" SwarmMember
	8) ansible -u rootmessages -m shell -a "hostname" SwarmMember
	9) rm /mnt/gluster/gluster_bpmspacecloud/tmp/id_rsa.pub

			
## DockerSwarm Initial Setup

BPMspaceCloud DockerSwarm is based on the Imixs-Cloud - https://github.com/imixs/imixs-cloud

_Imixs-Cloud_ is an open infrastructure project, providing a lightweight [docker](https://www.docker.com/) based container environment for production business applications. The main objectives of this project are **simplicity**, **transparency** and **operational readiness**. 
The _Imixs-Cloud_ is based on a [docker swarm](https://docs.docker.com/engine/swarm/) cluster environment.
Docker swarm is much easier to setup and in its management compared to a Kubernetes cluster. However, when deciding which platform  to use, you should consider your own criterias. _Imixs-Cloud_ is optimized to **build**, **run** and **maintain** business services in small and medium-sized enterprises.

### STEP I - ssh to docker-master-001 - login as rootmessages

	sudo /mnt/gluster/gluster_bpmspacecloud/BPMspaceCloud/bpmspace_step_05_01_dockerswarm.sh $MASTER001IP
	
	
### STEP II - ssh to docker-node-001 AND docker-node-002 - login as rootmessages

	sudo docker swarm join --token <TOKEN FROM STEP I-4>  <IP@MASTER>:2377 ..
	
### STEP III - ssh to docker-master-001 - login as rootmessages
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
			5ufqco634dq43usqulgnfvkb *	docker-master-001.bpmspace.net	Ready	Active		Leader		19.03.5
			vmk88y5o17q654b6az8l9p8x	docker-node-001.bpmspace.net	Ready	Active				19.03.5
			in0o2qh9iv8342ggzxcxiw15	docker-node-002.bpmspace.net	Ready	Active				19.03.5


### STEP IV  A - setup Portainer PROD in [Portainer Management Console](https:/portainer.bpmspace.net:8880)
Prerequisites:  
In the DNS a forward "IN A *.$DOCKERDOMAIN (wildcard) to $MASTER001IP" is configured  
In /mnt/gluster/gluster_bpmspacecloud/certs/ are valid certs
	
	1) sudo git -C /mnt/gluster/gluster_bpmspacecloud/BPMspaceCloud/ pull  
	2) sudo docker stack deploy -c /mnt/gluster/gluster_bpmspacecloud/BPMspaceCloud/dockerswarm/management/portainer/docker-compose.yml Portainer  
	3) https:/portainer.bpmspace.net:8880  
	
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

> sudo mkdir -p /mnt/gluster/gluster_bpmspacecloud/TEST_nginx-glusterfs on docker-node-001 or docker-node-002  
  
> Name:	TEST_nginx-glusterfs  
> Repository URL:	https://github.com/BPMspaceUG/BPMspaceCloud/  
> Compose path: /dockerswarm/apps/test/TEST_nginx-glusterfs/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST https://test_nginx-glusterfs.bpmspace.net/  
> ![#FFA500](https://placehold.it/15/FFA500/000000?text=+) TEST BASH: for ((n=0;n<1000000;n++));do printf "\033c"; echo "+++++++"; for ((m=0;m<5;m++)); do curl test_nginx-glusterfs.bpmspace.net; echo "-----"; done; sleep 3; done

### STEP XX - RESET System - incl volumes ![#FF0000](https://placehold.it/15/FF0000/000000?text=+) !!!! DANGER !!! ![#FF0000](https://placehold.it/15/FF0000/000000?text=+)
> docker container stop $(docker container ls -aq) && \  
> docker system prune --volumes &&  \  
> docker network create --driver=overlay --attachable cloud-net && \  
> docker network create --driver=overlay --attachable proxy-net && \  
> docker network ls | grep overlay  
> then go to step STEP IV 

