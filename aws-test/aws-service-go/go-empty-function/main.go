package main

import (
	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	Message string `json:"message"`
}

func Handler() (Response, error) {
	return Response{
		Message: "GOlang empty function return value",
	}, nil
}

func main() {
	lambda.Start(Handler)
}
