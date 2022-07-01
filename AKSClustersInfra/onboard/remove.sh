#!/usr/bin/env bash

# Variable is used by getopts.sh
# shellcheck disable=SC2034
SCRIPT_DESCRIPTION="Removes team resources from AKS"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_PATH}"/util/getopts.sh

echo "Starting off boarding, see detailed logs in ${LOG_DIR}"
echo
echo -n "Removing namespaces for ${NAME}..."
"${SCRIPT_PATH}"/util/delete-namespaces.sh -n "${NAME}" > "${LOG_DIR}/remove.log" 2> "${LOG_DIR}/remove.err"
echo 'done'
