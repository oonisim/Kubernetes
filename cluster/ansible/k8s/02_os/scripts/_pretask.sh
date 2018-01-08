#--------------------------------------------------------------------------------
# Place the application deployment artefacts in Ansible <role>/files/.
#
# <module>
# ├── roles
# │   └── site.os
# │       └── files <----- To here
# │           └── hosts
# └── scripts
#     └── main.sh   <--- This script
#--------------------------------------------------------------------------------
DIR=$(realpath $(dirname $0))
#FILES_DIR=$(realpath "$(dirname $0)")/../roles/hosts/files

#HOSTS=$(_locate ${DIR} '/' '2.0/conf')/env/${TARGET}/hosts.${TARGET}
#if [ -f ${HOSTS} ] ; then
#    ln -sf ${HOSTS} ${FILES_DIR}/hosts
#elif [ "${TARGET}" != "dev" ]; then
#    echo "There is no ${HOSTS} file. Do yo want to continue? Press CTRL+C to stop or resume in 30 sec"
#    sleep 30
#fi
