targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
//@allowed(['australiaeast', 'eastasia', 'eastus', 'eastus2', 'northeurope', 'southcentralus', 'southeastasia', 'uksouth', 'westus2'])
param location string

@description('Flag to use Azure API Management to mediate the calls between the Web frontend and the backend API')
param useAPIM bool = false

@description('API Management SKU to use if APIM is enabled')
param apimSku string = 'Consumption'

@description('Id of the user or app to assign application roles')
param principalId string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var functionAppName = '${abbrs.webSitesFunctions}api-${resourceToken}'
var deploymentStorageContainerName = 'app-package-${take(functionAppName, 32)}-${take(toLower(uniqueString(functionAppName, resourceToken)), 7)}'

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// User assigned managed identity to be used by the function app to reach Cosmos DB
module apiUserAssignedIdentity './core/identity/userAssignedIdentity.bicep' = {
  name: 'apiUserAssignedIdentity'
  scope: rg
  params: {
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}api-${resourceToken}'
  }
}

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}


// Give the API access to KeyVault
module apiKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  scope: rg
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: api.outputs.SERVICE_API_IDENTITY_PRINCIPAL_ID
  }
}


// The application database
module cosmos './app/db.bicep' = {
  name: 'cosmos'
  scope: rg
  params: {
    accountName: '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
    databaseName: 'todos'
    location: location
    tags: tags
    keyVaultName: keyVault.outputs.name
  }
}

// Backing storage for Azure functions backend processor
module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    name: '${abbrs.storageStorageAccounts}${resourceToken}'
    location: location
    tags: tags
    containers: [
      {name: deploymentStorageContainerName}
     ]
     networkAcls: {} 
  }
}

var storageRoleDefinitionId  = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner role

// Allow access from api to storage account using a managed identity
module storageRoleAssignmentApi 'core/storage/storage-Access.bicep' = {
  name: 'storageRoleAssignmentapi'
  scope: rg
  params: {
    storageAccountName: storage.outputs.name
    roleDefinitionID: storageRoleDefinitionId
    principalID: apiUserAssignedIdentity.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

module storageRoleAssignmentUserIdentityApi 'core/storage/storage-Access.bicep' = {
  name: 'storageRoleAssignmentUserIdentityApi'
  scope: rg
  params: {
    storageAccountName: storage.outputs.name
    roleDefinitionID: storageRoleDefinitionId
    principalID: principalId
    principalType: 'User'
  }
}

// The application function app
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: '${abbrs.webServerFarms}${resourceToken}'
    //kind: 'functionapp,linux'
    location: location
    tags: tags
    sku: {
      //name: 'FC1'
      //tier: 'FlexConsumption'
      //name: 'EP1'
      //tier: 'ElasticPremium'
      name: 'B1'
      tier: 'Basic'
    }
  }
}


// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
  }
}


//var monitoringRoleDefinitionId = '3913510d-42f4-4e42-8a64-420c390055eb' // Monitoring Metrics Publisher role ID

// Allow access from api to application insights using a managed identity
// module appInsightsRoleAssignmentApi './core/monitor/appinsights-access.bicep' = {
//   name: 'appInsightsRoleAssignmentapi'
//   scope: rg
//   params: {
//     appInsightsName: monitoring.outputs.applicationInsightsName
//     roleDefinitionID: monitoringRoleDefinitionId
//     principalID: apiUserAssignedIdentity.outputs.identityPrincipalId
//   }
// }

module api './app/api.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: functionAppName
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    // ERROR: error executing step command 'provision': deployment failed: error deploying infrastructure: deploying to subscription:

    // Deployment Error Details:
    // BadRequest: Site.FunctionAppConfig.Runtime.Name is invalid.  The specified value of runtime name 'custom' is not supported. Please set it to one of the allowed values: dotnet-isolated, java, node, python, powershell
    // - Site.FunctionAppConfig.Runtime.Name is invalid.  The specified value of runtime name 'custom' is not supported. Please set it to one of the allowed values: dotnet-isolated, java, node, python, powershell
    //runtimeName: 'custom'
    //runtimeVersion: ''  //TODO: what is the runtime version for custom?

    // $ func azure functionapp publish func-api-zpqecz5wmjtn6 --no-build
    // Your Azure Function App has 'FUNCTIONS_WORKER_RUNTIME' set to 'python' while your local project is set to 'custom'.
    // You can pass --force to update your Azure app with 'custom' as a 'FUNCTIONS_WORKER_RUNTIME'

    // $ func azure functionapp publish func-api-zpqecz5wmjtn6 --no-build --force
    // Setting 'FUNCTIONS_WORKER_RUNTIME' to 'custom' because --force was passed
    // We couldn't validate 'custom' runtime for Flex SKU in 'East US'.

    //runtimeName: 'custom'
    //runtimeVersion: ''
    
    storageAccountName: storage.outputs.name
    identityId: apiUserAssignedIdentity.outputs.identityId
    appSettings: {
      AZURE_COSMOS_CONNECTION_STRING_KEY: cosmos.outputs.connectionStringKey
      AZURE_COSMOS_DATABASE_NAME: cosmos.outputs.databaseName
      AZURE_COSMOS_ENDPOINT: cosmos.outputs.endpoint
    }
  }
}

// Data outputs
output AZURE_COSMOS_CONNECTION_STRING_KEY string = cosmos.outputs.connectionStringKey
output AZURE_COSMOS_DATABASE_NAME string = cosmos.outputs.databaseName

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output RESOURCE_GROUP string = rg.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output SERVICE_API_NAME string = api.outputs.SERVICE_API_NAME
output AZURE_FUNCTION_NAME string = api.outputs.SERVICE_API_NAME
output SERVICE_API_URI string = api.outputs.SERVICE_API_URI
output USE_APIM bool = useAPIM
//output SERVICE_API_ENDPOINTS array = useAPIM ? [ apimApi.outputs.SERVICE_API_URI, api.outputs.SERVICE_API_URI ]: []
