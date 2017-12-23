#!/usr/bin/env bash
ENVIRONMENT=aws
REMOTE_USER=centos

cd $(dirname $0)
#aws/ec2/creation/scripts/main.sh master
#aws/ec2/creation/scripts/main.sh worker
for module in $(find ./deploy -type d -maxdepth 1 -mindepth 1)
do
    ${module}/scripts/main.sh ${ENVIRONMENT} ${REMOTE_USER}
    if [ "${module##*/}" == "02_os" ] ; then
        echo "waiting the restart..."
        sleep 120
    fi
done