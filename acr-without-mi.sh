# Quelle: https://github.com/HoussemDellai/aca-course/tree/main/07_aca_workshop

#git clone https://github.com/HoussemDellai/aca-course.git
git clone https://github.com/tomalbrecht/containerapps-albumapi-python.git
git clone https://github.com/tomalbrecht/aca-course.git

$RESOURCE_GROUP="rg-containerapps-album-dev"
$LOCATION="westeurope"
$ACA_ENVIRONMENT="containerapps-env-album"
$ACA_BACKEND_API="album-api"
$ACA_FRONTEND_UI="album-ui"
$ACR_NAME="acracaalbums0136"

az group create `
         --name $RESOURCE_GROUP `
         --location $LOCATION

az acr create `
       --resource-group $RESOURCE_GROUP `
       --name $ACR_NAME `
       --sku Basic `
       --admin-enabled true

#az acr build --registry $ACR_NAME --image $ACA_BACKEND_API ../backend_api/backend_api_python/
az acr build --registry $ACR_NAME --image $ACA_BACKEND_API ./containerapps-albumapi-python/src

az containerapp env create `
                --name $ACA_ENVIRONMENT `
                --resource-group $RESOURCE_GROUP `
                --location $LOCATION

az containerapp create `
                --name $ACA_BACKEND_API `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API `
                --target-port 8080 `
                --ingress 'internal' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --query properties.configuration.ingress.fqdn

## neue Revision erstellen
az containerapp update `
                --name $ACA_BACKEND_API `
                --resource-group $RESOURCE_GROUP `
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API `
                --query properties.configuration.ingress.fqdn

## Löschen
# az containerapp delete `
#                 --name $ACA_BACKEND_API `
#                 --resource-group $RESOURCE_GROUP  

# Vorher Bugfixen der package.json!
# https://github.com/HoussemDellai/aca-course/pull/1/files
#az acr build --registry $ACR_NAME --image $ACA_FRONTEND_UI ../frontend_ui/
az acr build --registry $ACR_NAME --image $ACA_FRONTEND_UI ./aca-course/frontend_ui/

$API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_BACKEND_API --query properties.configuration.ingress.fqdn -o tsv)
echo $API_BASE_URL
# album-api.internal.purplepond-4fe75b66.westeurope.azurecontainerapps.io

az containerapp create `
  --name $ACA_FRONTEND_UI `
  --resource-group $RESOURCE_GROUP `
  --environment $ACA_ENVIRONMENT `
  --image $ACR_NAME'.azurecr.io/'$ACA_FRONTEND_UI  `
  --target-port 3000 `
  --env-vars API_BASE_URL=https://$API_BASE_URL `
  --ingress 'external' `
  --registry-server $ACR_NAME'.azurecr.io' `
  --query properties.configuration.ingress.fqdn
# "album-ui.purplepond-4fe75b66.westeurope.azurecontainerapps.io"
