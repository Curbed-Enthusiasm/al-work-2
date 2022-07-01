#!/usr/bin/env bash

# Variable is used by getopts.sh
# shellcheck disable=SC2034
SCRIPT_DESCRIPTION="Creates AD groups for team onboarding to AKS"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "${SCRIPT_PATH}"/getopts.sh

# TODO: Create AD Groups (SRE, DEV, READONLY)
# Name template aks-environment-team_name-(sre,dev,readonly)


7ed41c98-5fae-4ada-a836-2838b12af451