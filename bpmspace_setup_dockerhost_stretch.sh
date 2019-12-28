#!/bin/bash
#
set -e  # Stop execution of this script when an error occurs
#
#
#-------------------------------------------------------------------
# Install script for MITSM standard Linux server setup
#
# if you want to have a log of all stuff, please call the script as following:
#
# bpmspace_setup_dockerhost_stretch.sh | tee -a /tmp/install.log
#
# The script will execute the following steps:
#
# -user rootmessages will be created and authorized for sudo
# -git and curl will be installed
# -BPMspaceUG GIT repo will be cloned to /home/rootmessages
# -ssh configuration 
# -cron-apt for automatic security updates will be installed and configured
# -iptables configuration
# -apt update && apt upgrade
# -apt docker and docker compose
# -added sudo package and sudo rules
# -added hostname switch
# 
#
#-------------------------------------------------------------------
# after the script has finished, we need a reboot for all changes
# ssh daemon will not be restarted during the setup because otherwise you will
# get kicked out 
#-------------------------------------------------------------------

ENV=$1
HOST=$2

usage () {

  echo "$0 <LIVE|NOT_LIVE> <hostname>"
  echo "example: $0 NOT_LIVE smaug.einoede.org"

}

if [ $# -ne 2 ];then

  usage
  exit 1

fi

echo "Check if the script runs for the first time ...";

if [ -z "$DOCKER_ENV+x" ]; then 
	echo "First Installation $DOCKER_ENV does not exist"
	echo "DOCKER_ENV=$1" >> /etc/environment
	FIRSTTIME=TRUE;
else
 echo "SCRIPT was running at least once ... check something else";
 if [ $DOCKER_ENV == $ENV]; then
	echo "$DOCKER_ENV and $ENV are identical: '$ENV'"
	FIRSTTIME=FALSE;
	else
	echo "$DOCKER_ENV and $ENV are NOT identical DANGER! and exit"
	exit 1;
 fi
fi



apt update > /dev/null 2>&1

echo "let's install git, curl and sudo"
apt install -y git curl sudo

echo " "
echo "done."

echo " "
echo "creating user rootmessages... if not allready exists"
echo " "

id -u rootmessages &>/dev/null || adduser --quiet --disabled-password --gecos "" rootmessages 
id -u rootmessages &>/dev/null || adduser rootmessages sudo

echo "let's clone the BPMspaceUG GIT repo...."
cd /home/rootmessages
git clone https://github.com/BPMspaceUG/linux_config_script_files_II.git
git clone https://github.com/BPMspaceUG/bpmspace_docker2.git

echo "let's set hostname to $HOST"
echo $HOST > /etc/hostname

apt update > /dev/null 2>&1

echo " "
echo "SET SSH PORT to 7070"
cp /home/rootmessages/linux_config_script_files_II/dockerhost/daemon/sshd/sshd_config /etc/ssh/
mkdir -p /home/rootmessages/.ssh
cp /home/rootmessages/linux_config_script_files_II/dockerhost/authorized_keys/authorized_keys /home/rootmessages/.ssh

# Firewall stuff
echo "adding iptables script to /etc/rc.local"
# rc.local is still supported in stretch but will be deprecated in the future!
# there is no default rc.local to back-up
# mv /etc/rc.local /etc/rc.local.bak

echo "#!/bin/sh -e" > /etc/rc.local
echo "/opt/iptables.sh" >>/etc/rc.local
echo "exit 0" >> /etc/rc.local

# copy iptables.sh /opt
cp /home/rootmessages/linux_config_script_files_II/dockerhost/iptables/iptables.sh /opt
chmod u+x /opt/iptables.sh
chmod u+x /etc/rc.local

# install cron-apt for automatic security updates
echo "installing cron-apt to provide automatic security updates...."
echo " "
apt install -y cron-apt

echo "creating /etc/apt/action.d/5-secupdates"
echo " "
echo "upgrade -y -o APT::Get::Show-Upgraded=true" >> /etc/cron-apt/action.d/5-secupdates

echo "creating /etc/apt/security.list"
echo " "
echo "deb http://security.debian.org/ stretch/updates main contrib" > /etc/apt/security.list
echo "deb-src http://security.debian.org/ stretch/updates main contrib" >> /etc/apt/security.list

echo "OPTIONS=\"-q -o Dir::Etc::SourceList=/etc/apt/security.list\"" >> /etc/cron-apt/config.d/5-secupdates

echo " "
echo "we want to have an up2date server, so let's update all stuff."
echo " "
apt update > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1
apt dist-upgrade -y > /dev/null 2>&1

# install docker - https://linuxize.com/post/how-to-install-and-use-docker-on-debian-9/
echo "install docker"
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update > /dev/null 2>&1
apt install -y docker-ce
systemctl status docker
docker -v
usermod -aG docker rootmessages
# install docker-compsoe - https://linuxize.com/post/how-to-install-and-use-docker-compose-on-debian-9/
echo "install docker-compose"
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# sudo rules
echo "adding user to sudoers file...."
echo "rootmessages   ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers

echo " "
echo "change passwd for root - dont forget to document in lastpass"
passwd root
echo "change passwd for rootmessages - dont forget to document in lastpass"
passwd rootmessages


chown -R rootmessages:rootmessages /home/rootmessages
chmod 700 /home/rootmessages/.ssh
echo " "
echo "setup done. Please reboot"
echo " "

