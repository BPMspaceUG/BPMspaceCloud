#!/bin/bash
mkdir /mnt/gluster/ -p
mkdir /mnt/gluster/gluster_bpmspacecloud -p
echo 'localhost:/gluster_bpmspacecloud /mnt/gluster/gluster_bpmspacecloud glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab

if [ "$DOCKER_SWARM_TYPE" == "MASTER" ]; then
	cd /mnt/gluster/gluster_bpmspacecloud
	git clone https://github.com/BPMspaceUG/BPMspaceCloud.git
fi
if [ "$DOCKER_SWARM_TYPE" == "NODE" ]; then
	mkdir /mnt/gluster/gluster_bpmspacecloud_nodes -p
	echo 'localhost:/gluster_bpmspacecloud_nodes /mnt/gluster/gluster_bpmspacecloud_nodes glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab  
fi
rm -rf /root/BPMspaceCloud
mount -a
df -h  