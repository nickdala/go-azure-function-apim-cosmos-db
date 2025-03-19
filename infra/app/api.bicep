param name string
param location string = resourceGroup().location
param tags object = {}

param allowedOrigins array = []
param applicationInsightsName string = ''
param appServicePlanId string
@secure()
param appSettings object = {}
//param runtimeName string 
//param runtimeVersion string
param keyVaultName string
param serviceName string = 'api'
param storageAccountName string
param identityId string = ''


module api '../core/host/functions.bicep' = {
  name: '${serviceName}-functions-module'
    params: {
      name: name
      location: location
      tags: union(tags, { 'azd-service-name': serviceName })
      identityType: 'UserAssigned'
      identityId: identityId
      kind: 'functionapp,linux'
      allowedOrigins: allowedOrigins
      alwaysOn: false
      appSettings: appSettings
      applicationInsightsName: applicationInsightsName
      appServicePlanId: appServicePlanId
      keyVaultName: keyVaultName
      runtimeName: 'custom'
      runtimeVersion: ''
      storageAccountName: storageAccountName
      storageManagedIdentity: true
  }

}


// module api '../core/host/functions-flexconsumption.bicep' = {
//   name: '${serviceName}-functions-module'
//   params: {
//     name: name
//     location: location
//     tags: union(tags, { 'azd-service-name': serviceName })
//     identityType: 'UserAssigned'
//     identityId: identityId
//     appSettings: union(appSettings,
//       {
//         AzureWebJobsStorage__clientId : identityClientId
//         APPLICATIONINSIGHTS_AUTHENTICATION_STRING: applicationInsightsIdentity
//         AZURE_CLIENT_ID: identityClientId
//       })
//     applicationInsightsName: applicationInsightsName
//     appServicePlanId: appServicePlanId
//     runtimeName: runtimeName
//     runtimeVersion: runtimeVersion
//     storageAccountName: storageAccountName
//     deploymentStorageContainerName: deploymentStorageContainerName
//     virtualNetworkSubnetId: virtualNetworkSubnetId
//     instanceMemoryMB: instanceMemoryMB 
//     maximumInstanceCount: maximumInstanceCount
//   }
// }

output SERVICE_API_NAME string = api.outputs.name
output SERVICE_API_URI string = api.outputs.uri
output SERVICE_API_IDENTITY_PRINCIPAL_ID string = api.outputs.identityPrincipalId
