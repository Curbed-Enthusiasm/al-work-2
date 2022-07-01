#!/usr/bin/env bash

# Variable is used by getopts.sh
# shellcheck disable=SC2034
SCRIPT_DESCRIPTION="Creates namespaces for team onboarding to AKS"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_PATH}"/getopts.sh

NAMESPACES=("${ENVIRONMENTS[@]/#/${NAME}-}")
for namespace in "${NAMESPACES[@]}"
do
  kubectl create namespace "$namespace" || echo "WARNING: Could not create namespace ${namespace}"
  kubectl annotate --overwrite namespace "$namespace" linkerd.io/inject=enabled || echo "WARNING: Could not set up Linkerd for namespace ${namespace}"
  # In the future we can set up things like resource quotas, etc
done
