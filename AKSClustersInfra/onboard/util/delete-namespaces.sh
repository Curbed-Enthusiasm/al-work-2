#!/usr/bin/env bash

# Variable is used by getopts.sh
# shellcheck disable=SC2034
SCRIPT_DESCRIPTION="Deletes namespaces for team leaving AKS"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_PATH}"/getopts.sh

NAMESPACES=("${NAME}-dev" "${NAME}-test" "${NAME}-prod")
for namespace in "${NAMESPACES[@]}"
do
  kubectl delete namespace "$namespace" || echo "WARNING: Could not delete namespace ${namespace}"
done

exit 0
