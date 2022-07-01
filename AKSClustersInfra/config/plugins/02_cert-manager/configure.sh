#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f "$0"))

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install \
    --create-namespace \
    -n cert-manager \
    -f "${SCRIPT_PATH}/values.yaml" \
    cert-manager \
    jetstack/cert-manager \
    --wait

kubectl apply -f "${SCRIPT_PATH}/issuer.yaml"
