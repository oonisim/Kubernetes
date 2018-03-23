#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

. master

#export K8S_MASTER_HOSTNAME=${K8S_MASTER_HOSTNAME:?"Set K8S_MASTER_HOSTNAME"}
#export K8S_MASTER_NODE_IP=${K8S_MASTER_NODE_IP:?"Set K8S_MASTER_NODE_IP"}

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

#HOSTFILE_DIR=/Users/maonishi/home/repositories/git/Kubernetes/installations/ansible/deploy/02_os/roles/hosts/files
declare -a MODULES=(03_k8s 20_applications)


#for module in "${MODULES[@]}"
#do
#    deploy/${module}/scripts/main.sh ${ENVIRONMENT} ${REMOTE_USER}
#done

/Users/maonishi/home/repositories/git/k8s/installation/maintenance.sh

#--------------------------------------------------------------------------------
# Generate hosts file (/etc/hosts) from the EC2 instances created.
#--------------------------------------------------------------------------------
HOSTFILE="${DIR}/k8s/02_os/plays/roles/hosts/files/hosts"
./aws/ec2/operations/scripts/generate_hosts_file.sh ${ENVIRONMENT} ${HOSTFILE}


echo "Ready?"
read GO

for module in $(find ./k8s -type d -maxdepth 1 -mindepth 1)
do
    ${module}/scripts/main.sh \
        ${ENVIRONMENT} \
        ${REMOTE_USER} \
        -e K8S_MASTER_HOSTNAME=${K8S_MASTER_HOSTNAME} \
        -e K8S_MASTER_NODE_IP=${K8S_MASTER_NODE_IP}

    if [ "${module##*/}" == "02_os" ] ; then
        echo "waiting sever restarts"
        sleep 120
    fi
done


