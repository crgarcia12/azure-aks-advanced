[![Terraform Infrastructure Deployment](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/infra.yml/badge.svg)](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/infra.yml)
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
```