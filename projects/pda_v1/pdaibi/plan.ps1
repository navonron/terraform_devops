./proxy.ps1
$env:PROJECT_ID = "pda.pdaibi"
# dev or qa or prod
$env:PROJECT_ENVIRONMENT = "dev"
$env:TF_LOG=""
# Service Principal Client ID which has access to create the resources in `ARM_SUBSCRIPTION_ID` and persist the terraform remote state in `TF_BACKEND_STORAGE_ACCOUNT`
$env:ARM_CLIENT_ID = "69cfefd2-a820-4af8-970f-d4395dddecdd"
# Service Principal Client Secret
$env:ARM_CLIENT_SECRET = "Vdf8Q~mfd1G_qHwOiSP9V0PHUp1NYPBIYJF3fbR8"
# Subscription where the resource needs to be created.
# Subscription id should be added in the <environment>.tfvars
$env:ARM_SUBSCRIPTION_ID = "1fd3090a-949b-4ab5-b266-8fbb6701f677"
# Secrets needed for Azure Backend and Azure Provider
$env:ARM_TENANT_ID = "46c98d88-e344-4ed4-8496-4ed7712e255d"

# Variables needed for Backend
# Enterprise platform subscription
$env:TF_BACKEND_SUBSCRIPTION_ID = "1fd3090a-949b-4ab5-b266-8fbb6701f677"
# rg-iac-pprd-lyft for dev and qa. rg-iac-prod-uber for prod env.
$env:TF_BACKEND_RESOURCE_GROUP = "rg-pdaibi-terraform-dev"
# stiacpprdlyft for dev and qa. stiacproduber for prod env.
$env:TF_BACKEND_STORAGE_ACCOUNT = "sapdaibiterraformdev"
# vertical_id for verticals eg: smg and vertical_id.apt_id for apt eg: smg.retail
$env:PROJECT_ID = "pda.pdaibi"
# dev or qa or prod
$env:PROJECT_ENVIRONMENT = "dev"
$env:http_proxy="http://proxy-dmz.intel.com:911"
$env:HTTP_PROXY="http://proxy-dmz.intel.com:911"
$env:https_proxy="http://proxy-dmz.intel.com:912"
$env:HTTPs_PROXY="http://proxy-dmz.intel.com:912"

Write-Host "Using out file $env:PROJECT_ENVIRONMENT.tfplan with var file $env:PROJECT_ENVIRONMENT.tfvars"
terraform plan -out="$env:PROJECT_ENVIRONMENT.tfplan" -var-file="$env:PROJECT_ENVIRONMENT.tfvars"