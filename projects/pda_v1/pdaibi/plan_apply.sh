#!/bin/bash
set -e

source .env

echo -e "Running Terraform... Configuration: \n\
    Subscription:                   ${TF_BACKEND_SUBSCRIPTION_ID} \n\
    Resource Group:                 ${TF_BACKEND_RESOURCE_GROUP} \n\
    Storage Account Name:           ${TF_BACKEND_STORAGE_ACCOUNT} \n\
    Storage Account Container Name: tfstate \n\
    Project Id:                     ${PROJECT_ID} \n\
    Project Environment:            ${PROJECT_ENVIRONMENT} \n\
"

# Prompt the user to press Enter to continue
echo "Using out file ${PROJECT_ENVIRONMENT}.tfplan with var file ${PROJECT_ENVIRONMENT}.tfvars"
read -p "Press Enter to continue..."
terraform plan -out="${PROJECT_ENVIRONMENT}.tfplan" -var-file="${PROJECT_ENVIRONMENT}.tfvars" -target=module.key_vault

echo "Using ${PROJECT_ENVIRONMENT}.tfplan to apply the plan"
read -p "Press Enter to continue..."
terraform apply "${PROJECT_ENVIRONMENT}.tfplan"