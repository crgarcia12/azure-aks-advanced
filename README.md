[![Terraform Infrastructure Deployment](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/infra.yml/badge.svg)](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/infra.yml)
[![Build and deploy an app to AKS](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/app.yml/badge.svg)](https://github.com/crgarcia12/azure-aks-advanced/actions/workflows/app.yml)
[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/crgarcia12/azure-aks-advanced)
# azure-aks-advanced
This project tries out different AKS features:

# Load environment variables to work with these commands

```
if (!(gci .\.local.env.ps1)) { cp .\.template.env.ps1 .local.env.ps1 }
# complete the variables
. .local.env.ps1
```

# Set terraform
```
pwsh


az group create --name $resourceGroup --location $location
az storage account create --resource-group $resourceGroup --name $storageName --sku Standard_LRS
az storage container create --name tfstate --account-name $storageName
```

# Set GitHub secrets
Standing on the git directory:

```
# Create a Service Principal. The result is an array, concatenate it and convert to json
$servicePrincipalJson = az ad sp create-for-rbac --name "azure-aks-advanced-githubaction" --role owner --scopes /subscriptions/$subscriptionId --sdk-auth
$servicePrincipalJson = [string]::Concat($servicePrincipalJson)
$servicePrincipal = $servicePrincipalJson  | Convertfrom-json

gh secret set AZURE_CLIENT_ID     --repos crgarcia12/azure-aks-advanced --body $servicePrincipal.clientId
gh secret set AZURE_CLIENT_SECRET --repos crgarcia12/azure-aks-advanced --body $servicePrincipal.clientSecret
gh secret set AZURE_TENANT_ID     --repos crgarcia12/azure-aks-advanced --body $servicePrincipal.tenantId
gh secret set MVP_SUBSCRIPTION    --repos crgarcia12/azure-aks-advanced --body $servicePrincipal.subscriptionId
gh secret set AZURE_CREDENTIALS   --repos crgarcia12/azure-aks-advanced --body $servicePrincipalJson
```

# RabbitMQ installation
```
kubectl apply -f https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml

# Install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew install rabbitmq
alias k=kubectl
alias kr='kubectl rabbitmq'

kubectl config set-context --current --namespace=rabbitmq-cluster-ns
kr list

kr perf-test rabbitmq-cluster \
  --quorum-queue \
  --queue my-quorum-queue \
  --rate 1 \
  size 1

k logs perf-test-vmnng -f
kr secrets rabbitmq-cluster
kubectl get secret rabbitmq-cluster-default-user \
           -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret rabbitmq-cluster-default-user \
           -o jsonpath='{.data.password}' | base64 --decode



kubectl port-forward "service/rabbitmq-cluster" 15672
```

# Kustomize
Lot of good info and tips in here: https://blog.stack-labs.com/code/kustomize-101/

# Workload identity ## IN PROGRESS ##
```
export $(grep -v '^#' .env | xargs)
az account set --subscription $subscriptionId
az identity create --name $uami --resource-group $resourceGroup
$uamiClientId = az identity show -g $resourceGroup --name $uami --query 'clientId' -o tsv
$tenant = az aks show --name $clusterName --resource-group $resourceGroup --query identity.tenantId -o tsv

az keyvault set-policy -n $keyVault --key-permissions get --spn $uamiClientId
az keyvault set-policy -n $keyVault --secret-permissions get --spn $uamiClientId
az keyvault set-policy -n $keyVault --certificate-permissions get --spn $uamiClientId

$AksOidcIssuer = az aks show --resource-group $resourceGroup --name $clusterName --query "oidcIssuerProfile.issuerUrl" -o tsv
Write-Verbose $AksOidcIssuer -Verbose

kubectl get pods -n kube-system -l 'app in (secrets-store-csi-driver,secrets-store-provider-azure)'

az keyvault secret set --vault-name $keyVault -n SomeSecret --value TheSecretValue
k apply -f ..\app\aks-deployments\demoapp.yaml
k get all -n demoapp-ns

$federatedIdentityName = "workload-identity-feder-ident"
az identity federated-credential create --name $federatedIdentityName --identity-name $uami --resource-group $resourceGroup --issuer $AksOidcIssuer --subject system:serviceaccount:demoapp-ns:workload-identity-serv-acct

kubectl exec -n demoapp-ns --stdin --tty demoapp-deployment-6f4b8d587f-6blfg -- /bin/bash

------

# Azure Backup
```
az provider register --namespace Microsoft.KubernetesConfiguration
az provider show -n Microsoft.KubernetesConfiguration -o table
az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "TrustedAccessPreview"
# Wait for feature to be state:Registered
az feature show --namespace "Microsoft.ContainerService" --name "TrustedAccessPreview"

az k8s-extension create `
  --name azure-aks-backup `
  --extension-type microsoft.dataprotection.kubernetes `
  --scope cluster `
  --cluster-type managedClusters `
  --cluster-name $clusterName `
  --resource-group $resourceGroup  `
  --release-train stable `
  --debug `
  --configuration-settings `
    blobContainer=$blobContainer `
    storageAccount=$storageName `
    storageAccountResourceGroup=$resourceGroup `
    storageAccountSubscriptionId=$subscriptionId

az k8s-extension show --name azure-aks-backup --cluster-type managedClusters --cluster-name $clusterName --resource-group $resourceGroup

az role assignment create --assignee-object-id $(az k8s-extension show --name azure-aks-backup --cluster-name <aksclustername> --resource-group <aksclusterrg> --cluster-type managedClusters --query identity.principalId --output tsv) --role 'Storage Account Contributor' --scope /subscriptions/<subscriptionid>/resourceGroups/<storageaccountrg>/providers/Microsoft.Storage/storageAccounts/<storageaccountname>

```