#!/bin/bash
	# DOCKER_SWARM_TYPE MASTER or NODE
	echo "DOCKER_SWARM_TYPE=MASTER" >> /etc/environment
	# DOCKER_SWARM_ENV = PRODSTAGE or DEVTEST
	echo "DOCKER_SWARM_ENV=DEVTEST" >> /etc/environment
	# DOCKER_SWARM_SUBENV PRODSTAGE -> PROD OR STAGE / DEVTEST -> DEV OR TEST
	echo "DOCKER_SWARM_SUBENV=TEST" >> /etc/environment
	# DOCKERDOMAIN
	echo "DOCKERDOMAIN=bpmspace.net" >> /etc/environment
	# DOCKERHOSTNAME
	echo "DOCKERHOSTNAME=master_001.bpmspace.net" >> /etc/environment
	# DOCKERHOSTIP
	echo "DOCKERHOSTIP=<publicIP>" >> /etc/environment
	# DOCKERHOSTCLUSTERIP
	echo "DOCKERHOSTCLUSTERIP=<publicIP_node1>,<publicIP_node2>,<publicIP_node3>" >> /etc/environment
	# DOCKERPORTAINERIP
	echo "DOCKERPORTAINERIP=<publicIP>" >> /etc/environment
	# MASTER001IP
	echo "MASTER001IP=<publicIP>" >> /etc/environment
	# MASTER001NAME
	echo "MASTER001NAME=<HOSTNAME_MASTER_001>" >> /etc/environment
	# NODE001IP
	echo "NODE001IP=<publicIP>" >> /etc/environment
	# NODE001NAME
	echo "NODE001NAME=<HOSTNAME_NODE_001>" >> /etc/environment
	# NODE002IP
	echo "NODE002IP=<publicIP>" >> /etc/environment
	# NODE002NAME
	echo "NODE002NAME=<HOSTNAME_NODE_002>" >> /etc/environment

	#Set environement varaibles 
for env in $( cat /etc/environment ); do export $(echo $env | sed -e 's/"//g'); done
