#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

#--------------------------------------------------------------------------------
# Target environment/inventory and Ansibe remote_user to use
#--------------------------------------------------------------------------------
if [ -z ${TARGET_INVENTORY+x} ]; then
    echo "What is TARGET_INVENTORY?"
    read TARGET_INVENTORY
else
    echo "TARGET_INVENTORY is ${TARGET_INVENTORY}"
fi

if [ -z ${REMOTE_USER+x} ]; then
    echo "What is REMOTE_USER?"
    read REMOTE_USER
else
    echo "REMOTE_USER is ${REMOTE_USER}"
fi

#--------------------------------------------------------------------------------
# AWS information
# Not asking to type credentials from command line.
#--------------------------------------------------------------------------------
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY"}

#--------------------------------------------------------------------------------
# Master node information
#--------------------------------------------------------------------------------
if [ -f ./master ] ; then
    source master
fi

if [ -z ${K8S_MASTER_HOSTNAME+x} ]; then
    echo "What is K8S_MASTER_HOSTNAME?"
    read K8S_MASTER_HOSTNAME
else
    echo "K8S_MASTER_HOSTNAME is ${K8S_MASTER_HOSTNAME}"
fi

if [ -z ${K8S_MASTER_NODE_IP+x} ]; then
    echo "What is K8S_MASTER_NODE_IP?"
    read K8S_MASTER_NODE_IP
else
    echo "K8S_MASTER_NODE_IP is ${K8S_MASTER_NODE_IP}"
fi

#--------------------------------------------------------------------------------
# Generate hosts file (/etc/hosts) from the EC2 instances created.
#--------------------------------------------------------------------------------
#HOSTFILE="${DIR}/k8s/02_os/plays/roles/hosts/files/hosts"
#./aws/ec2/operations/scripts/generate_hosts_file.sh ${TARGET_INVENTORY} ${HOSTFILE}

#--------------------------------------------------------------------------------
# Run K8S setup
#--------------------------------------------------------------------------------
./maintenance.sh
for module in $(find ./cluster/ansible/k8s -type d -maxdepth 1 -mindepth 1)
do
    ${module}/scripts/main.sh \
        ${TARGET_INVENTORY} \
        ${REMOTE_USER} \
        -e K8S_MASTER_HOSTNAME=${K8S_MASTER_HOSTNAME} \
        -e K8S_MASTER_NODE_IP=${K8S_MASTER_NODE_IP}

    if [ "${module##*/}" == "02_os" ] ; then
        echo "waiting sever restarts"
        sleep 30
    fi
done
