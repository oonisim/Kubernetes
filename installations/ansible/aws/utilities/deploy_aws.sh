#!/bin/bash
set -eu
DIR=$(dirname $0)


echo "Target?"
read ENVIRONMENT

echo "ROOT_USER?"
read ROOT_USER

echo "Do you need web instance? (y/n)"
read web
if [ "${web}" == "y" ]; then
    ../aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} web
fi

echo "Do you need app instance? (y/n)"
read app
if [ "${app}" == "y" ]; then
../aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} app
fi

echo "Do you need dqe instance? (y/n)"
read dqe
if [ "${dqe}" == "y" ]; then
../aws/ec2/creation/scripts/main.sh ${ENVIRONMENT} dqe
fi

echo "creating hosts.${ENVIRONMENT} for /etc/hosts file in $(realpath ../conf/env/${ENVIRONMENT})"
../aws/ec2/operations/scripts/list_instances.sh ${ENVIRONMENT} $(realpath ../conf/env/${ENVIRONMENT})


echo "Do you want to run all? (y/n)"
read all
if [ "${all}" == "y" ]; then
../deploy/all/main.sh ${ENVIRONMENT} ${ROOT_USER}
fi
