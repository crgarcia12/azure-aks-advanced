[![Terraform Infrastructure Deployment](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/infra.yml/badge.svg)](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/infra.yml)
[![Build and deploy an app to AKS](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/app.yml/badge.svg)](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/app.yml)
[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/crgarcia12/azure-aks-advanced)
# azure-aks-advanced
This project tries out different AKS features:

# Set GitHub secrets
Standing on the git directory:

```
az ad sp create-for-rbac --name "crgar-glb-githubaction" --role owner --scopes /subscriptions/{subscriptionid} --sdk-auth

gh secret set AZURE_CLIENT_ID     --repos crgarcia12/azure-aks-advanced --body "<secret>"
gh secret set AZURE_CLIENT_SECRET --repos crgarcia12/azure-aks-advanced --body "<secret>"
gh secret set AZURE_TENANT_ID     --repos crgarcia12/azure-aks-advanced --body "<secret>"
gh secret set MVP_SUBSCRIPTION    --repos crgarcia12/azure-aks-advanced --body "<secret>"

$AZURECRED = @"
{
  "clientId": "<secret>",
  "clientSecret": "<secret>",
  "subscriptionId": "<secret>",
  "tenantId": "<secret>",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
"@

gh secret set AZURE_CREDENTIALS  --repos crgarcia12/azure-aks-advanced --body "$AZURECRED"

```
