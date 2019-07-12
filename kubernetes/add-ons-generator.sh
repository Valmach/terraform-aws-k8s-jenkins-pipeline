#!/usr/bin/env bash
set -e -o pipefail

echo "===================================================="
echo "Getting data from Terraform output..."
echo "===================================================="
TF_OUTPUT=$(cd ../terraform && terraform output -json)
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .k8s_cluster_name.value)"
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"

echo "Cluster Name...: ${CLUSTER_NAME}"
echo "Kops State.....: ${STATE}"

#Creating the output folder
mkdir -p output

echo "===================================================="
echo "Generating Add On yaml file..."
echo "===================================================="
echo "Ingress Controller..."
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template templates/nginx-ingress-controller-template.yaml --format-yaml > output/nginx-ingress-controller.yaml

echo "Heapster..."
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template templates/heapster-template.yaml --format-yaml > output/heapster.yaml

echo "Dashboard admin user"
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template templates/dashboard-admin-user-template.yaml --format-yaml > output/dashboard-admin-user.yaml
