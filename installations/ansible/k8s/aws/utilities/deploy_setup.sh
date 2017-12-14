#!/bin/bash
set -eu
DIR=$(dirname $0)

echo "Target ENV_ID?"
read ENVIRONMENT

#--------------------------------------------------------------------------------
# Check distribution
#--------------------------------------------------------------------------------
distro=$(cat /etc/os-release | grep '^NAME=' | sed -n 's/^NAME=\"\(.*\)\"$/\1/p')
if [[ ${distro:0:3} == "Ubu" ]] || [[ $distro == "Deb" ]] ;then
    SUDO_GROUP=sudo
    PKG_MAN=apt
elif [[ ${distro:0:3} == "Red" ]] || [[ $distro == "Cen" ]] ;then
    SUDO_GROUP=wheel
    PKG_MAN=yum
else
    msg_exit "Your linux system was not test"
fi

echo "#--------------------------------------------------------------------------------"
echo "# Install basic packages "
echo "#--------------------------------------------------------------------------------"
sudo ${PKG_MAN} update
sudo ${PKG_MAN} install -y openssh-server git zip unzip wget curl tree expect

echo "#--------------------------------------------------------------------------------"
echo "# Loading properties..."
echo "#--------------------------------------------------------------------------------"
source ../conf/env/${ENVIRONMENT}/env.properties
source ../conf/env/${ENVIRONMENT}/server.properties
sudo cat /dev/null

echo "#--------------------------------------------------------------------------------"
echo "# Adding ${SYS_USER}:${K8S_GROUP} to run Ansible in master (NOT at target)..."
echo "#--------------------------------------------------------------------------------"
sudo groupadd ${K8S_GROUP}
sudo useradd -m -s /bin/bash -G ${SUDO_GROUP},${K8S_GROUP} ${SYS_USER}
echo "${SYS_USER} ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${SYS_USER}
#sudo passwd ${SYS_USER}

sudo -u ${SYS_USER} mkdir -p /home/${SYS_USER}/.ssh
sudo -u ${SYS_USER} chmod 0700 /home/${SYS_USER}/.ssh
sudo cp    ${DIR}/private.pem /home/${SYS_USER}/.ssh/
sudo chown ${SYS_USER} /home/${SYS_USER}/.ssh/private.pem
sudo chmod go-rwx      /home/${SYS_USER}/.ssh/private.pem


#echo "#--------------------------------------------------------------------------------"
#echo "# Adding autheorized_keys. Provide password"
#echo "#--------------------------------------------------------------------------------"
#sudo -u ${SYS_USER} bash -c "cd && cat /dev/zero | ssh-keygen -q -N ''"
#sudo -u ${SYS_USER} ssh-copy-id ${SYS_USER}@localhost

echo "#--------------------------------------------------------------------------------"
echo "# Becoming the ${SYS_USER} to run Ansible playbooks. Do not logout"
echo "#--------------------------------------------------------------------------------"
sudo chown -R ${SYS_USER} ../../*
sudo su ${SYS_USER}
