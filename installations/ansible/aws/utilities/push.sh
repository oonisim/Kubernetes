#!/bin/bash
set -eux

. ../conf/env.properties
. ../conf/server.properties

rm -f ~/.ssh/known_hosts

#--------------------------------------------------------------------------------
# Create index sequence e.g. 05 06 07 ... from DQE_HOSTS
#--------------------------------------------------------------------------------
IFS=',' ids=(${DQE_HOSTS//${SERVER_TYPE_DQE}/})
unset IFS

#split -d -b 1584532358 100G.tgz
echo ${ids[@]}
for node in ${ids[@]}
do
    ssh -oStrictHostKeyChecking=no ${APP_USER}@dqe${node} "rm -rf ${APP_DATA_DIR}"
    scp -oStrictHostKeyChecking=no pull.sh  ${APP_USER}@dqe${node}:${APP_DATA_DIR}/ &
    scp -oStrictHostKeyChecking=no x${node} ${APP_USER}@dqe${node}:${APP_DATA_DIR}/ &
done
wait

for node in ${ids[@]}
do
    ssh compass@dqe${node} "cd ${DATA_DIR} && bash pull.sh ${DQE_HOSTS}" &
done
wait
