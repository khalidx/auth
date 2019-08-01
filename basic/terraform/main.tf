# Require a specific terraform version, or higher.
terraform {
  required_version = ">= 0.12"
}

# Provides data about the current region.
data "aws_region" "current" {}

# Provides data about the current account.
data "aws_caller_identity" "current" {}

# Sets the region and account for easy referencing in the terraform configuration.
locals {
  region  = "${data.aws_region.current.name}"
  account = "${data.aws_caller_identity.current.account_id}"
}

# The authorizer lambda function.
resource "aws_lambda_function" "lambda-authorizer-function" {
  depends_on                    = [
    "aws_cloudwatch_log_group.lambda-authorizer-log-group"
  ]
  function_name                 = "${var.name}"
  runtime                       = "nodejs10.x"
  memory_size                   = 256
  timeout                       = 3
  role                          = "${aws_iam_role.lambda-authorizer-function-role.arn}"
  handler                       = "authorizer.handler"
  filename                      = "${path.module}/../serverless/.serverless/authorizer.zip"
  source_code_hash              = "${filebase64sha256("${path.module}/../serverless/.serverless/authorizer.zip")}"
  environment {
    variables = {
      PARAMETER_STORE_NAMESPACE = "${var.name}"
    }
  }
  tags = {
    Name                        = "${var.name}"
  }
}

# The CloudWatch Log Group for the authorizer lambda function.
resource "aws_cloudwatch_log_group" "lambda-authorizer-log-group" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 90
}

# The role for the lambda authorizer function. This role gives the function
#   access to only read the parameters that begin with a specific path from
#   the AWS SSM Parameter Store.
resource "aws_iam_role" "lambda-authorizer-function-role" {
  name_prefix          = "${var.name}"
  permissions_boundary = "${var.permissions-boundary-for-roles}"
  assume_role_policy   = "${file("${path.module}/policies/lambda-assume-role.json")}"
  tags = {
    Name               = "${var.name}"
  }
}

# The execution policy for the role above. This reads the policy from a JSON
#   file and interpolates variables referenced in the file.
resource "aws_iam_role_policy" "lambda-execution-policy" {
  name_prefix = "${var.name}"
  role        = "${aws_iam_role.lambda-authorizer-function-role.id}"
  policy      = "${templatefile("${path.module}/policies/lambda-execution.json", {
    region    = "${local.region}"
    account   = "${local.account}"
    name      = "${var.name}"
  })}"
}

# Configures a response on the API Gateway Rest API when requests are not
#   authenticated. This response returns the `WWW-Authenticate` header, as
#   described by the HTTP Basic Authentication scheme.
resource "aws_api_gateway_gateway_response" "api-gateway-unauthorized-response" {
  # Only create this resource if api-id is provided, otherwise the Swagger
  #   document the user is using to configure their API is expected to have 
  #   this configuration.
  count = "${var.api-id == "" ? 0 : 1}" 
  rest_api_id   = "${var.api-id}"
  status_code   = "401"
  response_type = "UNAUTHORIZED"
  response_parameters = {
    "gatewayresponse.header.WWW-Authenticate" = "'Basic'"
  }
  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
}

# The API Gateway Rest API Authorizer configuration that associates the API 
#   with the authorizer.
resource "aws_api_gateway_authorizer" "api-gateway-authorizer" {
  # Only create this resource if api-id is provided, otherwise the Swagger
  #   document the user is using to configure their API is expected to have 
  #   this configuration.
  count = "${var.api-id == "" ? 0 : 1}" 
  name                             = "${var.name}"
  rest_api_id                      = "${var.api-id}"
  type                             = "TOKEN"
  authorizer_uri                   = "${aws_lambda_function.lambda-authorizer-function.invoke_arn}"
  authorizer_credentials           = "${aws_iam_role.api-gateway-role.arn}"
  identity_validation_expression   = "^x-[a-z]+"
  authorizer_result_ttl_in_seconds = 300
}

# The role for the API Gateway. This role allows the API Gateway to invoke 
#   the lambda authorizer function.
resource "aws_iam_role" "api-gateway-role" {
  name_prefix          = "${var.name}"
  permissions_boundary = "${var.permissions-boundary-for-roles}"
  assume_role_policy   = "${file("${path.module}/policies/api-gateway-assume-role.json")}"
  tags = {
    Name               = "${var.name}"
  }
}

# The execution policy for the role above. This reads the policy from a JSON
#   file and interpolates variable referenced in the file.
resource "aws_iam_role_policy" "api-gateway-invocation-policy" {
  name_prefix      = "${var.name}"
  role             = "${aws_iam_role.api-gateway-role.id}"
  policy           = "${templatefile("${path.module}/policies/api-gateway-invocation.json", {
    authorizer-arn = "${aws_lambda_function.lambda-authorizer-function.arn}"
  })}"
}
