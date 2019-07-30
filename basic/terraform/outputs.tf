output "authorizer-uri" {
  description = "The URI of the lambda authorizer function"
  value = "${aws_lambda_function.lambda-authorizer-function.invoke_arn}"
}

output "authorizer-credentials" {
  description = "The credentials for the API Gateway to invoke the lambda authorizer function"
  value = "${aws_iam_role.api-gateway-role.arn}"
}

output "api-key-source" {
  description = "The source for API keys for the API Gateway"
  value = "AUTHORIZER"
}

output "authorization" {
  description = "The type of authorization used for a protected API method"
  value = "CUSTOM"
}

output "authorizer-id" {
  description = "The id of the API Gateway authorizer configuration"
  value = "${aws_api_gateway_authorizer.api-gateway-authorizer.id}"
}

output "api-key-required" {
  description = "Sets a requirement for an API key for a protected API method"
  value = true
}
