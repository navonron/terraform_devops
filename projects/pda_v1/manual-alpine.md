# Instructions for manual execution:

## Source .env
```bash
source .env
```

## Run init
```bash
sh init.sh
```
OR
```bash
echo -e "Running Terraform init, Configuration: \n\
    Subscription:                   ${TF_BACKEND_SUBSCRIPTION_ID} \n\
    Resource Group:                 ${TF_BACKEND_RESOURCE_GROUP} \n\
    Storage Account Name:           ${TF_BACKEND_STORAGE_ACCOUNT} \n\
    Storage Account Container Name: tfstate \n\
    Project Id:                     ${PROJECT_ID} \n\
    Project Environment:            ${PROJECT_ENVIRONMENT} \n\
"

terraform init \
    -backend-config="subscription_id=${TF_BACKEND_SUBSCRIPTION_ID}" \
    -backend-config="resource_group_name=${TF_BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${TF_BACKEND_STORAGE_ACCOUNT}" \
    -backend-config="container_name=tfstate" \
    -backend-config="key=${PROJECT_ID}.${PROJECT_ENVIRONMENT}.tfstate"
    #-backend-config="use_microsoft_graph=true"
```

## Run Plan
```bash
echo "Using out file ${PROJECT_ENVIRONMENT}.tfplan with var file ${PROJECT_ENVIRONMENT}.tfvars"
terraform plan -out="${PROJECT_ENVIRONMENT}.tfplan" -var-file="${PROJECT_ENVIRONMENT}.tfvars"
```

## Run Apply
```bash
terraform apply "${PROJECT_ENVIRONMENT}.tfplan"
```

## Run Destroy
```bash
terraform destroy -var-file="${PROJECT_ENVIRONMENT}.tfvars" -auto-approve
```
