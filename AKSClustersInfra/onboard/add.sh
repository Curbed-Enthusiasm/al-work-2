#!/usr/bin/env bash

# Variable is used by getopts.sh
# shellcheck disable=SC2034
SCRIPT_DESCRIPTION="Runs onboarding steps to get a team up and running on AKS"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_PATH}"/util/getopts.sh

echo "Starting onboarding, see detailed logs in ${LOG_DIR}"
echo
echo -n "Creating namespaces for ${NAME}..."
"${SCRIPT_PATH}"/util/create-namespaces.sh -n "${NAME}" > "${LOG_DIR}/add.log" 2> "${LOG_DIR}/add.err"
echo 'done'
