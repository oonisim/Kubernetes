#!/usr/bin/env bash
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY"}

DIR=$(realpath $(dirname $0))
cd ${DIR}

ENVIRONMENT=aws
REMOTE_USER=centos

maintenance.sh

#--------------------------------------------------------------------------------
# Setup AWS and create master file which holds master node data in ${DIR}
# The master file is then used by run_k8s.sh
#--------------------------------------------------------------------------------
cluster/ansible/aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} ${DIR}

