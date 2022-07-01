#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f "$0"))

if ! kubectl get secret -n linkerd linkerd-trust-anchor > /dev/null 2>&1; then
  if [[ -f "${SCRIPT_PATH}"/ca.crt ]] && [[ -f "${SCRIPT_PATH}"/ca.key ]]; then
    # brew install step
    step certificate create root.linkerd.cluster.local ca.crt ca.key \
      --profile root-ca --no-password --insecure -f
  fi
  kubectl create secret tls \
    linkerd-trust-anchor \
    --cert="${SCRIPT_PATH}"/ca.crt \
    --key="${SCRIPT_PATH}"/ca.key \
    --namespace=linkerd
fi

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: linkerd-trust-anchor
  namespace: linkerd
spec:
  ca:
    secretName: linkerd-trust-anchor
EOF

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: linkerd-identity-issuer
  namespace: linkerd
spec:
  secretName: linkerd-identity-issuer
  duration: 48h
  renewBefore: 25h
  issuerRef:
    name: linkerd-trust-anchor
    kind: Issuer
  commonName: identity.linkerd.cluster.local
  dnsNames:
  - identity.linkerd.cluster.local
  isCA: true
  privateKey:
    algorithm: ECDSA
  usages:
  - cert sign
  - crl sign
  - server auth
  - client auth
EOF
