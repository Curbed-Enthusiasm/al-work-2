#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f "$0"))

if [ -z "${LOG_DIR}" ]; then
  export LOG_DIR=$(mktemp -d "/tmp/aks_configure.XXXXX")
fi

export LOG_FILE="${LOG_DIR}/plugins.log"
export ERROR_FILE="${LOG_DIR}/plugins.err"

function configure {
  DIR_PATH=$1
  NAME=$(cut -d'_' -f2 <<< "${DIR_PATH/${SCRIPT_PATH}//}")
  echo -n "${NAME}..."
  echo "-------Starting ${NAME}-------" | tee -a "${LOG_FILE}" "${ERROR_FILE}" >/dev/null
  if ! "${DIR_PATH}"/configure.sh >> "${LOG_FILE}" 2>> "${ERROR_FILE}"; then
    echo "Error occured while installing ${NAME}, please see ${ERROR_FILE} for details"
    exit 1
  fi
  echo "-------Finished ${NAME}-------" | tee -a "${LOG_FILE}" "${ERROR_FILE}" >/dev/null
  echo 'done'
}
declare -xf configure

find "${SCRIPT_PATH}" -type d -maxdepth 1 -mindepth 1 | sort | xargs -I {} bash -c "configure {}"
