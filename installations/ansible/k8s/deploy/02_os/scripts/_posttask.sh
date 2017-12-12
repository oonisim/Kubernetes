#--------------------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------------------
ORIGINAL=$(realpath ${FILES_DIR}/hosts)
rm -f ${FILES_DIR}/hosts

# Remove the original hosts.${TARGET} to avoid re-using the obsolete one.
# Create the hosts file for each run.
# [12OCT2017] Stop removing. If obsolete file is there, it is an operation bug which the deployer needs to fix.
#rm -f ${ORIGINAL}