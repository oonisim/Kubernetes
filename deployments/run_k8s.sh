#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

. master

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

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY"}


ENVIRONMENT=aws
REMOTE_USER=centos

#--------------------------------------------------------------------------------
# Generate hosts file (/etc/hosts) from the EC2 instances created.
#--------------------------------------------------------------------------------
#HOSTFILE="${DIR}/k8s/02_os/plays/roles/hosts/files/hosts"
#./aws/ec2/operations/scripts/generate_hosts_file.sh ${ENVIRONMENT} ${HOSTFILE}

./maintenance.sh
for module in $(find ./cluster/ansible/k8s -type d -maxdepth 1 -mindepth 1)
do
    ${module}/scripts/main.sh \
        ${ENVIRONMENT} \
        ${REMOTE_USER} \
        -e K8S_MASTER_HOSTNAME=${K8S_MASTER_HOSTNAME} \
        -e K8S_MASTER_NODE_IP=${K8S_MASTER_NODE_IP}

    if [ "${module##*/}" == "02_os" ] ; then
        echo "waiting sever restarts"
        sleep 30
    fi
done
