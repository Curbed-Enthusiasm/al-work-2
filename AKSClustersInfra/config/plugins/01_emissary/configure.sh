#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f "$0"))

helm repo add datawire https://app.getambassador.io
helm repo update

# Install CRDs
kubectl apply -f https://app.getambassador.io/yaml/emissary/2.2.2/emissary-crds.yaml
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system

helm upgrade --install -n emissary --create-namespace \
     -f "${SCRIPT_PATH}/values.yaml" \
     emissary-ingress datawire/emissary-ingress

kubectl rollout status  -n emissary deployment/emissary-ingress -w
