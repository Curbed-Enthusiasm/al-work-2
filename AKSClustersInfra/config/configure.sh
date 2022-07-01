#!/bin/bash

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))
export LOG_DIR=$(mktemp -d "/tmp/aks_configure.XXXXX")
unset SKIP_CONFIRM
unset CONTEXT

function usage {
  echo "$0 [ -c CONTEXT ] [ -f ]" 1>&2
}

function help {
  echo "Add description of the script functions here."
  echo
  usage
  echo "options:"
  echo "c     Kube context to use when running setup."
  echo "f     Run without confirming kube context (USE ONLY IF YOU UNDERSTAND THE IMPLICATIONS)"
  echo "h     Shares this help."
  echo
  exit 0
}

function exit_abnormal {
  usage
  exit 1
}

function confirm_cluster {
  echo "Your kube context is set to $(kubectl config current-context)."
  read -p "Is this the cluster you would like to configure? [y/n] " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    echo
    echo "Please select the correct cluster with \`kubectl config set-context \${NAME}\` out of the following options:"
    echo
    kubectl config get-contexts
    echo
    echo "If you don't see the correct cluster, you may need to use the following to gain access. The resource group"
    echo "and cluster name can be found in the Azure portal."
    printf "\taz aks get-credentials --resource-group \${RESOURCE_GROUP} --name \${CUSTER_NAME}\n"
    exit 1
  fi
}

function configure_cluster {
  echo "Starting setup, see detailed logs in ${LOG_DIR}"
  echo
  echo "Configuring Plugins"
  "${SCRIPT_PATH}/plugins/configure.sh"
  echo "Plugins Configured"
  echo
  echo "Configuring Resources"
  "${SCRIPT_PATH}/resources/configure.sh"
  echo "Resources Configured"
}

while getopts ":c:fh" options; do
  case "${options}" in
    c)
      kubectl config use-context "${OPTARG}" || exit 1
      SKIP_CONFIRM=true
      ;;
    f)
      SKIP_CONFIRM=true
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

if [ -z ${SKIP_CONFIRM+x} ]; then
  confirm_cluster
fi

configure_cluster
