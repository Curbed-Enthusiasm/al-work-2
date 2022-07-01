#!/usr/bin/env bash

unset NAME
ENVIRONMENTS=('dev' 'test' 'prod')
export LOG_DIR=${LOG_DIR:=$(mktemp -d "/tmp/aks_onboard.XXXXX")}

function echo_warn {
  echo -e "\033[33m$*\033[0m"
}

function echo_error {
  echo -e "\033[0;31m$*\033[0m" 1>&2
}

function validate_team_name {
  name=$1
  NAME_REGEX="^[a-z0-9]([-a-z0-9]{0,56}[a-z0-9])$"
  if [[ ! "$name" =~ ${NAME_REGEX} ]]; then
    echo_error "Name must be a compliant DNS label (RFC1123), no more than 58 characters."
    echo_error "Match the following regular expression: ${NAME_REGEX}"
    echo
    exit_abnormal
  fi
}

usage() {
  echo "$0 <-n NAME> [-h]" 1>&2
}

function help {
  echo "${SCRIPT_DESCRIPTION:='Script missing description'}"
  echo
  usage
  echo "options:"
  echo " n     Name of the team. MUST BE A COMPLIANT DNS LABEL (RFC1123) NO MORE THAN 58 CHARS"
  echo " h     Shares this help."
  exit 0
}

exit_abnormal() {
  usage
  exit 1
}

while getopts ":n:h" options; do
  case "${options}" in
    n)
      NAME=${OPTARG}
      validate_team_name "${NAME}"
      ;;
    h)
      help
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

if [ -z "${NAME}" ]; then
  echo_error "A valid name must be provided. Use -h for more information"
  exit_abnormal
fi
