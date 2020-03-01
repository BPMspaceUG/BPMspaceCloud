#!/bin/bash
echo " "
echo "let's set hostname to $DOCKERHOSTNAME"
echo $DOCKERHOSTNAME > /etc/hostname
echo " "

echo " "
echo "creating user rootmessages... if not allready exists"
echo " "

id -u rootmessages &>/dev/null || adduser --quiet --disabled-password --gecos "" rootmessages 
id -u rootmessages &>/dev/null || adduser rootmessages sudo

echo " "
echo "UPDATE, UPGRADE and INSTALL"
echo " "
apt update 
apt upgrade 
apt dist-upgrade -y 
apt install -y cron-apt 
apt install -y xfsprogs 
apt install -y glusterfs-server 
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
apt install -y ansible 
cp /root/BPMspaceCloud/dockerhost/ansible/hosts /etc/ansible/

echo " "
echo "install docker"
echo " "
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update 
apt upgrade -y 
apt install -y docker-ce 
usermod -aG docker rootmessages

echo " "
echo "install docker-compose"
echo " "
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo " "
echo "enable docker Gluster"
systemctl enable docker
systemctl start glusterfs-server
echo " "

echo " "
echo "CONFIG SSH"
echo " "
cp /root/BPMspaceCloud/dockerhost/daemon/sshd/sshd_config /etc/ssh/
mkdir -p /home/rootmessages/.ssh
cp /root/BPMspaceCloud/dockerhost/authorized_keys/authorized_keys /home/rootmessages/.ssh

echo " "
echo "adding rootmessages to sudoers file...."
echo " "
echo "rootmessages   ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers
chown -R rootmessages:rootmessages /home/rootmessages
chmod 700 /home/rootmessages/.ssh

echo " "
echo "creating /etc/apt/action.d/5-secupdates"
echo " "
echo "upgrade -y -o APT::Get::Show-Upgraded=true" >> /etc/cron-apt/action.d/5-secupdates
echo " "
echo "creating /etc/apt/security.list"
echo " "
echo "deb http://security.debian.org/ stretch/updates main contrib" > /etc/apt/security.list
echo "deb-src http://security.debian.org/ stretch/updates main contrib" >> /etc/apt/security.list
echo "OPTIONS=\"-q -o Dir::Etc::SourceList=/etc/apt/security.list\"" >> /etc/cron-apt/config.d/5-secupdates


echo " "
echo "adding iptables script to /etc/rc.local"
echo " "
echo "#!/bin/sh -e" > /etc/rc.local
echo "for env in \$( cat /etc/environment ); do export \$env; done">>/etc/rc.local
echo "/opt/iptables.sh" >>/etc/rc.local
echo "exit 0" >> /etc/rc.local
cp /root/BPMspaceCloud/dockerhost/iptables/iptables.sh /opt
chmod u+x /opt/iptables.sh
chmod u+x /etc/rc.local

echo " "
passwd_rootmessages=$(passwd -S rootmessages | cut -d ' ' -f 2)
while [ "$passwd_rootmessages" != "P" ]
do
	echo "change passwd for rootmessages - don't forget to document in lastpass - rootmessages passwd MUST not be empty"
	passwd rootmessages
	passwd_rootmessages=$(passwd -S rootmessages | cut -d ' ' -f 2)
done
echo " "
echo "change INITIAL passwd for root - dont forget to document in lastpass - root passwd MUST not be empty"
passwd root
echo " "

echo "change bash promt of root (red) and rootmessages (green) "
cat /root/BPMspaceCloud/dockerhost/bashrc/rootmessages.bash.rc >> /home/rootmessages/.bashrc
cat /root/BPMspaceCloud//dockerhost/bashrc/root.bash.rc >> /root/.bashrc


echo "setup done. ready to reboot ..."
reboot