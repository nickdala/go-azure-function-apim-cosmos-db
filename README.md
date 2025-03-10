# Azure Functions APIM and Cosmos DB for MongoDB

This repository contains a sample Azure Functions project in [Go](https://go.dev/) that demonstrates how to use Azure API Management (APIM) and Azure Cosmos DB for MongoDB together. The project includes a set of HTTP-triggered functions that interact with a Cosmos DB database.

## Prerequisites
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Go](https://golang.org/dl/)

There is a [DevContainer](https://code.visualstudio.com/docs/remote/containers) that can be used to build the project in a container. This is useful if you don't have Go installed on your machine.

You can open the project in Visual Studio Code and select the "Reopen in Container" option. Or you can use [CodeSpaces](https://github.com/features/codespaces) to build the project in the cloud.

## Build

To build the Azure Functions project, run the following command in the root directory of the project:

```bash
go build handler.go
```
This will create an executable file named `handler` in the root directory.

## Run the Docker Container

The project includes a `docker-compose.yml` file that defines a Docker container for MongoDB. To run the container, use the following command:

```bash
docker compose up -d
```
This will start a MongoDB container in detached mode. You can access the MongoDB instance at `mongodb://localhost:27017`.

## Start the Azure Functions Host

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

## Test the Functions

You can use a tool like [Postman](https://www.postman.com/) or [curl](https://curl.se/) to send the request.

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