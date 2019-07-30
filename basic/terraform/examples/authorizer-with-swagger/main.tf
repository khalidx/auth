# Use the authorizer module from this repository
module "authorizer" {
  # When using any module in this repository in your own templates, you will need to use
  #   a Git URL with a ref attribute that pins you to a specific version of the module,
  #   such as the following example:
  # source = "git::git@github.com:khalidx/auth.git//modules/authorier?ref=v1.0.0"
  source  = "../../"

  # Here are some common options that you can provide to the module. For a full list of  
  #   options (and more information about each one) see the variables.tf file.
  name    = "authorizer-with-swagger"
  api-id  = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_rest_api" "api" {
  description = "A sample API for demonstrating the authorizer."
  name        = "authorizer-with-swagger-api"
  body        = "${file("${path.module}/swagger.yaml")}"
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "test"
}

output "api-deployment-url" {
  description = "The url for the sample API for demonstrating the authorizer"
  value       = "${aws_api_gateway_deployment.api-deployment.invoke_url}/hello"
}
