git clone https://github.com/HoussemDellai/aca-course.git

## Managed Identity
cd ./aca-course/08_aca_workshop_mi/

$RESOURCE_GROUP="rg-containerapps-album-dev-v3"
$LOCATION="westeurope"
$ACA_ENVIRONMENT="containerapps-env-album"
$ACA_BACKEND_API="album-api"
$ACA_FRONTEND_UI="album-ui"
$ACR_NAME="acracaalbums0135"
$IDENTITY="identity-aca-acr"

az group create `
         --name $RESOURCE_GROUP `
         --location $LOCATION

az acr create `
       --resource-group $RESOURCE_GROUP `
       --name $ACR_NAME `
       --sku Basic `
       --admin-enabled false
az acr build --registry $ACR_NAME --image $ACA_BACKEND_API ../backend_api/backend_api_csharp/
#az acr build --registry $ACR_NAME --image $ACA_BACKEND_API ../backend_api/backend_api_python/

az containerapp env create `
                --name $ACA_ENVIRONMENT `
                --resource-group $RESOURCE_GROUP `
                --location $LOCATION

az identity create --resource-group $RESOURCE_GROUP --name $IDENTITY

$IDENTITY_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY --query clientId -o tsv)
$ACR_ID=$(az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query id)
#$ACR_ID="subscriptions/7d0b488f-2937-43b5-a55b-ed7a16d435cd/resourceGroups/rg-containerapps-album-dev-v3/providers/Microsoft.ContainerRegistry/registries/acracaalbums0135"

az role assignment create `
        --role AcrPull `
        --assignee $IDENTITY_CLIENT_ID `
        --scope $ACR_ID

$IDENTITY_RESOURCE_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY --query id -o tsv)
echo $IDENTITY_RESOURCE_ID

az containerapp create `
                --name $ACA_BACKEND_API `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API `
                --target-port 3500 `
                --ingress 'internal' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID `
                --query properties.configuration.ingress.fqdn

az acr build --registry $ACR_NAME --image $ACA_FRONTEND_UI ../frontend_ui/

$API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_BACKEND_API --query properties.configuration.ingress.fqdn -o tsv)
echo $API_BASE_URL

az containerapp create `
                --name $ACA_FRONTEND_UI `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_FRONTEND_UI  `
                --target-port 3000 `
                --env-vars API_BASE_URL=https://$API_BASE_URL `
                --ingress 'external' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID `
                --query properties.configuration.ingress.fqdn
# "album-ui.purplepond-4fe75b66.westeurope.azurecontainerapps.io"
