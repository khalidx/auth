# Require a specific terraform version, or higher.
terraform {
  required_version = ">= 0.12"
}

# The terraform provider for the Amazon Web Services cloud.
provider "aws" {}

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
    "aws_iam_role_policy_attachment.lambda-execution-policy-attachment",
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
resource "aws_iam_policy" "lambda-execution-policy" {
  name_prefix = "${var.name}"
  policy      = "${templatefile("${path.module}/policies/lambda-execution.json", {
    region    = "${local.region}"
    account   = "${local.account}"
    name      = "${var.name}"
  })}"  
}

# Attaches the execution policy to the role.
resource "aws_iam_role_policy_attachment" "lambda-execution-policy-attachment" {
  role       = "${aws_iam_role.lambda-authorizer-function-role.name}"
  policy_arn = "${aws_iam_policy.lambda-execution-policy.arn}"
}
