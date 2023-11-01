# Constants:
$SUBSCRIPTION="1fd3090a-949b-4ab5-b266-8fbb6701f677"
$RESOURCE_GROUP_NAME="rg-pdaibi-terraform-dev"
$STORAGE_ACCOUNT_NAME="sapdaibiterraformdev"
$STORAGE_CONTAINER_NAME="tfstate"
# Create a resource group for the ADLS container.
# if (az group exists --name $RESOURCE_GROUP_NAME){
#     Write-Host "Resource Group '$RESOURCE_GROUP_NAME' already exists."
# }
# else{
#     Write-Host "Creating Resource Group '$RESOURCE_GROUP_NAME'."
#     az group create --location westus2 --name $RESOURCE_GROUP_NAME --subscription $SUBSCRIPTION --verbose
# }
# az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --location westus2 --sku Standard_LRS --allow-blob-public-access false
az storage container create --name $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --public-access off --resource-group $RESOURCE_GROUP_NAME --fail-on-exist --auth-mode login --verbose


# az group delete --name $RESOURCE_GROUP_NAME --subscription $SUBSCRIPTION --verbose