#!/usr/bin/env bash
set -eu
. ~/.ssh/aws_env_keys.sh

ENVIRONMENT=aws
REMOTE_USER=centos
HOSTFILE_DIR=/Users/maonishi/home/repositories/git/Kubernetes/installations/ansible/deploy/02_os/roles/hosts/files
declare -a MODULES=(03_k8s 20_applications)

cd $(dirname $0)

#for module in "${MODULES[@]}"
#do
#    deploy/${module}/scripts/main.sh ${ENVIRONMENT} ${REMOTE_USER}
#done

/Users/maonishi/home/repositories/git/Kubernetes/maintenance.sh
for module in $(find ./deploy -type d -maxdepth 1 -mindepth 1)
do
    if [ "${module##*/}" != "02_os" ] ; then
        ${module}/scripts/main.sh ${ENVIRONMENT} ${REMOTE_USER}
    fi
done