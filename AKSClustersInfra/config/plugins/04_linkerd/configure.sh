#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f "$0"))

# add the repo for stable releases:
helm repo add linkerd https://helm.linkerd.io/stable

kubectl create namespace linkerd 2>/dev/null; :

"${SCRIPT_PATH}/tls-anchor.sh"

kubectl annotate --overwrite namespace linkerd app.kubernetes.io/managed-by=Helm
kubectl annotate --overwrite namespace linkerd meta.helm.sh/release-name=linkerd2
kubectl annotate --overwrite namespace linkerd meta.helm.sh/release-namespace=linkerd
kubectl label --overwrite namespace linkerd app.kubernetes.io/managed-by=Helm
kubectl label --overwrite namespace kube-system config.linkerd.io/admission-webhooks=disabled
kubectl annotate --overwrite namespace emissary linkerd.io/inject=enabled

# for stable
helm upgrade --install linkerd2 \
  --create-namespace \
  -n linkerd \
  --version '2.10.2' \
  --set-file identityTrustAnchorsPEM="${SCRIPT_PATH}/ca.crt" \
  --set identity.issuer.scheme=kubernetes.io/tls \
  -f "${SCRIPT_PATH}/values.yaml" \
  -f "${SCRIPT_PATH}/values-ha.yaml" \
  linkerd/linkerd2

linkerd viz install | kubectl apply -f -

# Restart Emissary so that it's included in the mesh
kubectl get deployment -n emissary -oname | xargs kubectl rollout restart -n emissary
