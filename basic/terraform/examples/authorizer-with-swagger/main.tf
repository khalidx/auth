# Use the authorizer module from this repository
module "authorizer" {
  # When using any module in this repository in your own templates, you will need to use
  #   a Git URL with a ref attribute that pins you to a specific version of the module,
  #   such as the following example:
  # source = "github.com/khalidx/auth.git//basic/terraform?ref=master"
  source  = "../../"

  # Here are some common options that you can provide to the module. For a full list of  
  #   options (and more information about each one) see the variables.tf file.
  name    = "authorizer-with-swagger"
}

resource "aws_api_gateway_rest_api" "api" {
  description              = "A sample API for demonstrating the authorizer."
  name                     = "authorizer-with-swagger-api"
  body                     = "${templatefile("${path.module}/swagger.yaml", {
    authorizer-uri         = "${module.authorizer.authorizer-uri}"
    authorizer-credentials = "${module.authorizer.authorizer-credentials}"
  })}"
}

# Force re-deployment if the Swagger spec or dependencies change.
#   This has nothing to do with this module. This is just a way
#   to make sure the latest API is always deployed. This is an
#   existing open issue in terraform.
# https://github.com/hashicorp/terraform/issues/6613
# https://github.com/terraform-providers/terraform-provider-aws/issues/162
# https://github.com/terraform-providers/terraform-provider-aws/pull/9245
resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id       = "${aws_api_gateway_rest_api.api.id}"
  stage_name        = "test"
  stage_description = "swaggerHash is ${filebase64sha256("${path.module}/swagger.yaml")}"
  lifecycle {
    create_before_destroy = true
  }
}

output "api-deployment-url" {
  description = "The url for the sample API for demonstrating the authorizer"
  value       = "${aws_api_gateway_deployment.api-deployment.invoke_url}/hello"
}
