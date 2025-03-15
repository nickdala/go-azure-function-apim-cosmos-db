# Azure Functions APIM and Cosmos DB for MongoDB

This repository contains a sample Azure Functions project in [Go](https://go.dev/) that demonstrates how to use Azure API Management (APIM) and Azure Cosmos DB for MongoDB together. The project includes a set of HTTP-triggered functions that interact with a Cosmos DB database.

## Prerequisites
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Go](https://golang.org/dl/)
- [Azure Dev CLI](https://learn.microsoft.com/en-us/azure/developer/azd/install-azd)
- [Docker](https://www.docker.com/get-started)

There is a [DevContainer](https://code.visualstudio.com/docs/remote/containers) that can be used to build the project in a container. This is useful if you don't have Go installed on your machine.

You can open the project in Visual Studio Code and select the "Reopen in Container" option. Or you can use [CodeSpaces](https://github.com/features/codespaces) to build the project in the cloud.

## Local Development

### Build the Project

To build the Azure Functions project, run the following command in the root directory of the project:

```bash
go build handler.go
```
This will create an executable file named `handler` in the root directory.

### Run the Docker Container

The project includes a `docker-compose.yml` file that defines a Docker container for MongoDB. To run the container, use the following command:

```bash
docker compose up -d
```
This will start a MongoDB container in detached mode. You can access the MongoDB instance at `mongodb://localhost:27017`.

### Start the Azure Functions Host

To start the Azure Functions host, run the following command in the root directory of the project:

```bash
func start
```
This will start the Azure Functions host and listen for incoming HTTP requests. The functions will be available at `http://localhost:7071/api/{functionName}`.

You should see output similar to the following:

```bash
Functions:

        create-or-update-todos: [POST] http://localhost:7071/api/todos

        get-all-todos: [GET] http://localhost:7071/api/todos

        get-todo: [GET] http://localhost:7071/api/todos/{id}

        hello: [GET] http://localhost:7071/api/hello
```

## Deploy to Azure

### 1. Log in to Azure
Before deploying, you must be authenticated to Azure and have the appropriate subscription selected. Run the following command to authenticate:

```
az login
```

If you have multiple tenants, you can use the following command to log into the tenant:

```shell
az login --tenant <tenant-id>
```

Set the subscription to the one you want to use (you can use az account list to list available subscriptions):

```
export AZURE_SUBSCRIPTION_ID="<your-subscription-id>"
```

```
az account set --subscription $AZURE_SUBSCRIPTION_ID
```

Use the next command to login with the Azure Dev CLI (AZD) tool:

```
azd auth login
```

If you have multiple tenants, you can use the following command to log into the tenant:

```
azd auth login --tenant-id <tenant-id>
```

### 2. Create a new environment

Next we provide the AZD tool with variables that it uses to create the deployment. The first thing we initialize is the AZD environment with a name.

```
azd env new <pick_a_name>
```

Select the subscription that will be used for the deployment:

```
azd env set AZURE_SUBSCRIPTION_ID $AZURE_SUBSCRIPTION_ID
```

Set the Azure region to be used:

```
azd env set AZURE_LOCATION <pick_a_region>
```

### 3. Create the Azure resources and deploy the code

Run the following command to create the Azure resources and deploy the code (about 15-minutes to complete):

```
azd up
```

The deployment process will output the URL of the deployed application.

```
Deploying services (azd deploy)

  (✓) Done: Deploying service application
  - Endpoint: https://app-nickdalasql.azurewebsites.net/


SUCCESS: Your application was deployed to Azure in 19 seconds.
```

### 4. Tear down the deployment

Run the following command to tear down the deployment:

```pwsh
azd down --purge --force
```

## Test the Functions

Whether you are running the functions locally or have deployed them to Azure, you can test the functions using HTTP requests.

You can use a tool like [Postman](https://www.postman.com/) or [curl](https://curl.se/) to send the request.

HTTP requests either go to the local host or the Azure URL, depending on whether you are running locally or have deployed to Azure. The local host URL is `http://localhost:7071/api/{functionName}` and the Azure URL is `https://<your-app-name>.azurewebsites.net/api/{functionName}`.


### Get the Hello Function
To test the hello function, run the fullowing.

```bash
curl -X GET http://localhost:7071/api/hello
```
This will send a GET request to the `/api/hello` endpoint. You should see a response similar to the following:

```json
{
  "message": "Hello, World!"
}
```

### Create a Todo Item

To create a new todo item, send a POST request to the `/api/todos` endpoint with the following JSON payload:

```json
{
  "title": "Buy groceries",
  "done": false
}
```

Below is an example of how to do this using `curl`:

```bash
curl -X POST http://localhost:7071/api/todos \
-H "Content-Type: application/json" \
-d '{
  "title": "Buy groceries",
  "done": false
}'
```

### Get All Todo Items

To get all todo items, send a GET request to the `/api/todos` endpoint:

```bash
curl -X GET http://localhost:7071/api/todos
```
This will return a list of all todo items in the database.

### Get a Todo Item by ID
To get a specific todo item by its ID, send a GET request to the `/api/todos/{id}` endpoint, replacing `{id}` with the actual ID of the todo item:

```bash
curl -X GET http://localhost:7071/api/todos/{id}
```

This will return the details of the specified todo item.

### Update a Todo Item

To update a todo item, send a PUT request to the `/api/todos/{id}` endpoint with the updated JSON payload:

```bash
curl -X POST http://localhost:7071/api/todos \
-H "Content-Type: application/json" \
-d '{
  "id": "{id}",
  "title": "Buy groceries",
  "done": true
}'
```





#### TODO Change the following to PUT
```bash
curl -X PUT http://localhost:7071/api/todos/{id} \
-H "Content-Type: application/json" \
-d '{
  "title": "My Todo",
  "done": true
}'
```
This will update the specified todo item in the database.