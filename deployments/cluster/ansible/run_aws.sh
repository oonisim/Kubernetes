#!/usr/bin/env bash
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"Set AWS_ACCESS_KEY_ID"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"Set AWS_SECRET_ACCESS_KEY"}

DIR=$(realpath $(dirname $0))
cd ${DIR}

ENVIRONMENT=aws
REMOTE_USER=centos

/Users/maonishi/home/repositories/git/k8s/installation/maintenance.sh
./aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} ${DIR}

