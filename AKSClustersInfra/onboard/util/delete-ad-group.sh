#!/usr/bin/env bash

# Variable is used by getopts.sh
# shellcheck disable=SC2034
SCRIPT_DESCRIPTION="Deletes AD groups for team leaving AKS"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_PATH}"/getopts.sh

# TODO: Delete AD Groups (SRE, DEV, READONLY)
# Name template aks-environment-team_name-(sre,dev,readonly)
