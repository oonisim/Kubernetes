#!/bin/bash
#--------------------------------------------------------------------------------
# Run the ansible playbook.
#--------------------------------------------------------------------------------
set -eu
DIR=$(realpath $(dirname $0))
. ${DIR}/_utility.sh

if [ $# -eq 2 ]; then
    ENVIRONMENT=$1
    NODE_TYPE=$2
else
    echo "Target?"
    read ENVIRONMENT

    echo "Server type (master|worker)?"
    read NODE_TYPE
fi

PLAYBOOK_DIR=$(realpath "$(dirname $0)/../plays")
ARGS="\
 -e ENV_ID=${ENVIRONMENT}\
 -e NODE_TYPE=${NODE_TYPE}"

$(_locate ${DIR} '/' 'conductor.sh') ${PLAYBOOK_DIR} ${ENVIRONMENT} ${ARGS}
