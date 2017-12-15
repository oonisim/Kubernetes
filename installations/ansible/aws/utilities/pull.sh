#!/bin/bash
set -eu
script=$(realpath $0)

if [ $# -le 0 ] ; then exit 0 ; fi

. ../conf/env.properties
. ../conf/server.properties

#--------------------------------------------------------------------------------
# Identify the hostname of this DQE server.
#--------------------------------------------------------------------------------
IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
NAME=$(getent hosts | grep ${IP} | grep ${SERVER_TYPE_DQE} | tr -s " " | cut -d ' ' -f3)

#--------------------------------------------------------------------------------
# Identify DQE node id, e.g. 04 for dqe04.
#--------------------------------------------------------------------------------
ID=${NAME#${SERVER_TYPE_DQE}}

#--------------------------------------------------------------------------------
# Create index sequence e.g. 05 06 07 ...
#--------------------------------------------------------------------------------
IFS=',' ids=(${@//${SERVER_TYPE_DQE}/})
unset IFS

echo ${ids[@]}

#--------------------------------------------------------------------------------
# If this host is in the node list, remove it and rotate the list so that it
# start with the next node. e.g. 00 01 02 03 04 05 06 is the list and this is 04,
# then create 05 06 00 01 02 03 and start SCP from 05.
#--------------------------------------------------------------------------------
i=0
while [ ${i} -lt ${#ids[@]} ]
do
    if [ "${ID}" == "${ids[ ${i} ]}" ] ; then
        set -- ${ids[@]: $((i + 1))} ${ids[@]: 0:${i}}
        break
    fi
    i=$(( i + 1))
done

#--------------------------------------------------------------------------------
# Copy
#--------------------------------------------------------------------------------
MAX_CONN=3
connection=0

while [ $# -gt 0 ]
do
    until [ ${connections} -eq ${MAX_CONN} ] || [ $# -eq 0 ]
    do
        connections=$(( connections + 1 ))
        scp -oStrictHostKeyChecking=no compass@dqe${1}:${STAGING_DIR}/x${1} . &
        shift
    done
    wait

    connections=0
done
#exec ${script} $@

#--------------------------------------------------------------------------------
# Reconstruct the compressed file.
#--------------------------------------------------------------------------------
MERGED=100G.tgz
LOCATION="bigdisk/large_data/large_test/100GB"
cat ${APP_DATA_DIR}/x* > ${APP_DATA_DIR}/${MERGED}

MD5EXPECTED=d1414c265e5a9454133ff9025661e3bf
MD5ACTUAL=($(md5sum ${APP_DATA_DIR}/${MERGED}))
if [ "${MD5ACTUAL}" != "${MD5EXPECTED}" ] ; then
    echo "--------------------------------------------------------------------------------"
    echo " NODE [$NAME] MD5 does not match. Aborting"
    echo " Expected is ${MD5EXPECTED} actual is ${MD5ACTUAL}" | tee ${APP_DATA_DIR}/MD5.log
    echo " $(ls -lt x*)"
    echo "--------------------------------------------------------------------------------"
    exit 1
fi

#--------------------------------------------------------------------------------
# Remove the split files to save space.
#--------------------------------------------------------------------------------
find ${APP_DATA_DIR} -mindepth 1 -not \( -name "x${ID}" -o -name "${MERGED}" -o -name "*.sh" \) | xargs rm -rf

#--------------------------------------------------------------------------------
# Extract data files in ${APP_DATA_DIR}
#--------------------------------------------------------------------------------
tar -xzvf ${APP_DATA_DIR}/${MERGED} -C ${APP_DATA_DIR}
cp -rs ${APP_DATA_DIR}/${LOCATION}/*.csv ${APP_DATA_DIR}

#--------------------------------------------------------------------------------
# Remove the compressed file.
#--------------------------------------------------------------------------------
rm ${APP_DATA_DIR}/${MERGED}
