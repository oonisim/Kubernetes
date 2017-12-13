#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Set the exec permission to scripts in the repository.
#--------------------------------------------------------------------------------
find . -name '*.sh' | xargs -I % bash -c 'git add %; chmod u+x %; git update-index --chmod=+x % '

