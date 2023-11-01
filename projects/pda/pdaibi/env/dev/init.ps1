Write-Host "Initializing Proxies for Intel network"
$env:HTTP_PROXY = "http://proxy-chain.intel.com:912"
$env:HTTPS_PROXY = "http://proxy-chain.intel.com:912"
$env:no_proxy= "localhost,127.0.0.1,intel.com,windows.net,azure.net"

$env:ARM_CLIENT_ID = "69cfefd2-a820-4af8-970f-d4395dddecdd"
$env:ARM_CLIENT_SECRET = "Vdf8Q~mfd1G_qHwOiSP9V0PHUp1NYPBIYJF3fbR8"
$env:ARM_SUBSCRIPTION_ID = "1fd3090a-949b-4ab5-b266-8fbb6701f677"
$env:ARM_TENANT_ID = "46c98d88-e344-4ed4-8496-4ed7712e255d"

$env:TF_BACKEND_SUBSCRIPTION_ID = "1fd3090a-949b-4ab5-b266-8fbb6701f677"
$env:TF_BACKEND_RESOURCE_GROUP = "rg-pdaibi-terraform-dev"
$env:TF_BACKEND_STORAGE_ACCOUNT = "sapdaibiterraformdev"
$env:PROJECT_ID = "pda.pdaibi"
$env:PROJECT_ENVIRONMENT = "dev"

$env:TF_LOG="DEBUG"

$command = terraform init `
    -backend-config="subscription_id=$env:TF_BACKEND_SUBSCRIPTION_ID" `
    -backend-config="resource_group_name=$env:TF_BACKEND_RESOURCE_GROUP" `
    -backend-config="storage_account_name=$env:TF_BACKEND_STORAGE_ACCOUNT" `
    -backend-config="container_name=tfstate" `
    -backend-config="key=$env:PROJECT_ID.$env:PROJECT_ENVIRONMENT.tfstate" `
$command
