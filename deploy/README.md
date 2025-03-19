# Azure Deployment Instructions

This directory contains Bicep templates to deploy the Go Azure Function with Cosmos DB MongoDB API.

## Prerequisites

- Azure CLI installed
- Login to Azure: `az login`
- Set subscription: `az account set --subscription <subscription-id>`

## Deployment Steps

1. Create a resource group (if needed):
   ```bash
   az group create --name <resource-group-name> --location <location>
   ```

2. Deploy the Bicep template:
   ```bash
   az deployment group create \
     --resource-group <resource-group-name> \
     --template-file main.bicep \
     --parameters environmentName=dev
   ```

## Post-Deployment

After deployment, you need to:

1. Build and package your Go function app
2. Deploy the package to the function app using:
   ```bash
   az functionapp deployment source config-zip -g <resource-group-name> -n <function-app-name> --src <zip-file-path>
   ```
