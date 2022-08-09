#!/bin/bash

## Script to create two service accounts and onboard list of people
if [[ ! $1 ]]; then
  echo "Use following way: ./set-kube-config.sh 192.168.1.0"
  exit 1
fi

if [[ $1 =~ '443' ]]; then
  KUBERNETES_ENDPOINT="https://$1"
else
  KUBERNETES_ENDPOINT="https://$1:443"
fi

NAMESPACE="kube-system"
ADMIN_SERVICE_ACCOUNT='common-admin'
SERVICE_ACCOUNT='common-view'

if kubectl get sa -n "${NAMESPACE}" "${ADMIN_SERVICE_ACCOUNT}" > /dev/null 2>&1; then
  echo "Service Account $ADMIN_SERVICE_ACCOUNT already exist"
else
  kubectl create serviceaccount -n "${NAMESPACE}" "${ADMIN_SERVICE_ACCOUNT}"
  kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=view --serviceaccount="${NAMESPACE}":"${ADMIN_SERVICE_ACCOUNT}"
fi

if kubectl get  serviceaccount -n "${NAMESPACE}" "${SERVICE_ACCOUNT}" > /dev/null 2>&1; then
  echo "Service account $SERVICE_ACCOUNT already exist"
else
  kubectl create sa -n "${NAMESPACE}" "${SERVICE_ACCOUNT}"
  kubectl create clusterrolebinding root-cluster-view-binding --clusterrole=view --serviceaccount="${NAMESPACE}":"${SERVICE_ACCOUNT}"
fi
echo "Serviceaccounts and clusterrolebindings are created ready to use"

function generate_kube_config() {
  local SERVICE_ACCOUNT="$1"
  local NAMESPACE="$2"
  local KUBE_CONFIG_NAME="$3"
  SECRET_NAME=$(kubectl get "serviceaccount/${SERVICE_ACCOUNT}" -n "${NAMESPACE}" -o jsonpath='{.secrets[].name}')
  ca=$(kubectl get "secret/$SECRET_NAME" -n "${NAMESPACE}" -o jsonpath='{.data.ca\.crt}')
  token=$(kubectl get "secret/$SECRET_NAME" -n "${NAMESPACE}"  -o jsonpath='{.data.token}' | base64 --decode)
  echo "apiVersion: v1
  kind: Config
  clusters:
  - name: fuchicorp-cluster
    cluster:
      certificate-authority-data: ${ca}
      server: ${KUBERNETES_ENDPOINT}
  contexts:
  - name: fuchicorp-context
    context:
      cluster: fuchicorp-cluster
      namespace: fuchicorp
      user: fuchicorp-user
  current-context: fuchicorp-context
  users:
  - name: fuchicorp-user
    user:
      token: ${token}
  " | sed 's/^  //g' > ./"${KUBE_CONFIG_NAME}"
  echo "Crated config file: ./${KUBE_CONFIG_NAME}"
}

generate_kube_config "${ADMIN_SERVICE_ACCOUNT}" "${NAMESPACE}" "admin_config"
generate_kube_config "${SERVICE_ACCOUNT}" "${NAMESPACE}" "view_config"
