#!/usr/bin/env bash
. ~/.ssh/aws_env_keys.sh

ENVIRONMENT=aws
REMOTE_USER=centos
HOSTFILE_DIR=/Users/maonishi/home/repositories/git/Kubernetes/installations/ansible/deploy/02_os/roles/hosts/files

cd $(dirname $0)
./aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} master
./aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} worker
./aws/ec2/operations/scripts/generate_hosts.sh ${ENVIRONMENT} ${HOSTFILE_DIR}

echo "update the env"
read GO

for module in $(find ./deploy -type d -maxdepth 1 -mindepth 1)
do
    ${module}/scripts/main.sh ${ENVIRONMENT} ${REMOTE_USER}
    if [ "${module##*/}" == "02_os" ] ; then
        echo "waiting the restart..."
        sleep 120
    fi
done