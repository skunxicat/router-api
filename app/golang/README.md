# golang

This example deploy a sample lambda function build in `golang` and deployed as docker image following the workflow suggested by AWS in the following doc.

https://docs.aws.amazon.com/lambda/latest/dg/go-image.html

If you haven't already, provision the resources (ecr, ssm, ...) defined in the tf configuration.

```bash

npm run terraform init 
npm run terraform apply

```

```bash
mkdir -p src && cd src

go mod init ql4b.com/handler
go get github.com/aws/aws-lambda-go/lambda

touch main.go
```

Edit the your business logic inside `main.go`

```go
package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	response := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       "\"Hello from Lambda!\"",
	}
	return response, nil
}

func main() {
	lambda.Start(handler)
}
```

Build the lambda runtime docker image.

You can use the provided npm script to build and push the docker image

```bash
    # build development image
    npm run runtime:golang:build:dev
```

or

```bash
docker buildx build \   
    --platform linux/arm64 \
    --provenance=false \
    -t lambda-golang-runtime:dev . --laod
```

Run locally:

```bash
docker run -d -p 9000:8080 \
    --platform linux/arm64 \
    --entrypoint /usr/local/bin/aws-lambda-rie \
    lambda-golang-runtime:dev ./main
```

NOTE: If you have built the image using the npm scriptm the image name and tag used are generated from terraform output so if you intend to run the container locally for testing, make sure you use the correct `image:tag` in the previous command.

Test invoking lambda locally:

```bash
curl --silent \
    "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}' \
    | jq 
```

You should see an output similar to this one: 

```json
{
  "statusCode": 200,
  "headers": null,
  "multiValueHeaders": null,
  "body": "\"Hello from Lambda!\""
}
```



```

```

To deploy the lambda function run

```bash
    # build & push to the remote repo && 
    #  provision the lambda function 
    npm run runtime:golang:build &&  \
        npm run serverless -- deploy --stage <staging> 
```

NOTE: The shortcut command `npm run deploy` build,  push and deploy everything (including the funtions running or different runtimes)

