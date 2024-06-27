## Local Setup

- Install VSCode
- [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Run the 

## Azure Deployment (without Managed Identity)
> Microsoft recommends a deployment with managed identity!


### Set configurations
```zsh
RESOURCE_GROUP="rg-aca-album-dev-python"
LOCATION="westeurope"
ACA_ENVIRONMENT="aca-env-album"
ACA_BACKEND_API="album-api"
ACA_FRONTEND_UI="album-ui"
ACR_NAME="acracaalbums0138"
```

### Create resource group
```zsh
az group create \
         --name $RESOURCE_GROUP \
         --location $LOCATION
```

### Create container registry
```zsh
az acr create \
       --resource-group $RESOURCE_GROUP \
       --name $ACR_NAME \
       --sku Basic \
       --admin-enabled true
```

### Build backend
```zsh
az acr build --registry $ACR_NAME \
       --image $ACA_BACKEND_API ./aca-albumapi-python/src
```

### Create environment
```zsh
az containerapp env create \
                --name $ACA_ENVIRONMENT \
                --resource-group $RESOURCE_GROUP \
                --location $LOCATION
```

### Create backend container
```zsh
az containerapp create \
                --name $ACA_BACKEND_API \
                --resource-group $RESOURCE_GROUP \
                --environment $ACA_ENVIRONMENT \
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API \
                --target-port 8080 \
                --ingress 'internal' \
                --registry-server $ACR_NAME'.azurecr.io' \
                --query properties.configuration.ingress.fqdn
```

### Build frontend image
```zsh
az acr build --registry $ACR_NAME --image $ACA_FRONTEND_UI ./aca-frontend-python/
```

### Show API endpoint
```zsh
API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_BACKEND_API --query properties.configuration.ingress.fqdn -o tsv)
echo $API_BASE_URL
# album-api.internal.purplepond-4fe75b66.westeurope.azurecontainerapps.io
```

### Build frontend container
```zsh
az containerapp create \
  --name $ACA_FRONTEND_UI \
  --resource-group $RESOURCE_GROUP \
  --environment $ACA_ENVIRONMENT \
  --image $ACR_NAME'.azurecr.io/'$ACA_FRONTEND_UI  \
  --target-port 3000 \
  --env-vars API_BASE_URL=https://$API_BASE_URL \
  --ingress 'external' \
  --registry-server $ACR_NAME'.azurecr.io' \
  --query properties.configuration.ingress.fqdn
# "album-ui.purplepond-4fe75b66.westeurope.azurecontainerapps.io"
```

## // THE END


## Misc

### Create new revision of the backend container
```zsh
az containerapp update \
                --name $ACA_BACKEND_API \
                --resource-group $RESOURCE_GROUP \
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API \
                --query properties.configuration.ingress.fqdn
```

### Delete the backend container
```zsh
az containerapp delete \
                --name $ACA_BACKEND_API \
                --resource-group $RESOURCE_GROUP  
```

### Delete the resource group with all resources
```zsh
az group delete --name $RESOURCE_GROUP
```
