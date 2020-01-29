#!/bin/bash
usage () {

  echo "$0 disk"
  echo "example: $0 sdb"

}

if [ $# -ne 1 ];then

  usage
  exit 1

fi

DISK=$1

echo " "
echo "let's create some directories"
mkdir -p /gluster/  
mkdir -p /gluster/bricks/  
mkdir -p /gluster/bricks/$DOCKERHOSTNAME
mkdir -p /gluster/bricks/$DOCKERHOSTNAME/brick
mkdir -p /gluster/bricks/$DOCKERHOSTNAME/brick2
echo '/dev/$DISK /gluster/bricks/$DOCKERHOSTNAME xfs defaults 0 0' >> /etc/fstab
mount -a
echo " "
df -h  
echo " "
