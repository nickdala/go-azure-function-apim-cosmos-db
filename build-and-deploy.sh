FUNCTION_NAME=$(azd env get-values --output json | jq -r .azure_function_name)

GOOS=linux GOARCH=amd64 go build handler.go
func azure functionapp publish $FUNCTION_NAME --no-build