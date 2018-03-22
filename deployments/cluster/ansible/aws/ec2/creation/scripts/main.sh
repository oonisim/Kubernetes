#!/bin/bash
#--------------------------------------------------------------------------------
# Run the ansible playbook.
#--------------------------------------------------------------------------------
set -eu
DIR=$(realpath $(dirname $0))
. ${DIR}/_utility.sh

if [ $# -eq 2 ]; then
    ENVIRONMENT=$1
    OUTPUT_DIR=$2
else
    echo "Target?"
    read ENVIRONMENT

    echo "Output directory?"
    read OUTPUT_DIR
fi

PLAYBOOK_DIR=$(realpath "$(dirname $0)/../plays")
ARGS="\
    -e ENV_ID=${ENVIRONMENT} \
    -e OUTPUT_DIR=${OUTPUT_DIR}"

$(_locate ${DIR} '/' 'conductor.sh') ${PLAYBOOK_DIR} ${ENVIRONMENT} ${ARGS}
