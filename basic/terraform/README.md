# authorizer-basic

- [authorizer-basic](#authorizer-basic)
  - [Usage](#usage)
    - [With Swagger](#with-swagger)
    - [Without Swagger](#without-swagger)
  - [Support](#support)

## Usage

Make sure you have `terraform` installed with a version greater than `0.12`.

It also helps to set the following environment variables before running any `terraform` commands.

```sh
export AWS_PROFILE=<some-profile>
export AWS_REGION=<some-region>
```

For example:

```sh
export AWS_PROFILE=personal-aws-account
export AWS_REGION=us-east-1
```

To use this module directly, import it into your `terraform` document with the following configuration.

```terraform
module "authorizer" {
  source = "git::git@github.com:khalidx/auth.git//basic/terraform?ref=v1.0.0"
  
  ...module configuration options go here...
}
```

This module allows you to configure your AWS API Gateway with a Swagger/OpenAPI specification document. If you *aren't* using Swagger, the module will still correctly configure your API.

To see an example of this module fully imported and configured, browse either:

- the `./examples/authorizer-with-swagger/` directory
- the `./examples/authorizer-without-swagger/` directory

Both examples deploy a sample API to the AWS API Gateway that is properly configured to use the authorizer.

For the Swagger example, pay special attention to any `x-amazon-apigateway-` configurations in the `swagger.yaml` file as well as the comments in the well-documented `main.tf` file. Reading both documents in the example will help you understand how all the components fit and work together.

To deploy an example, browse into the directory for the example and run the following commands.

```sh
terraform init
terraform apply
```

### With Swagger

If you *are* using Swagger:

1. import the module:

```terraform
module "authorizer" {
  source  = "git::git@github.com:khalidx/auth.git//basic/terraform?ref=v1.0.0"
}
```

2. configure your API Gateway using your Swagger file; for example:

```terraform
resource "aws_api_gateway_rest_api" "api" {
  ...

  body                     = "${templatefile("${path.module}/swagger.yaml", {
    authorizer-uri         = "${module.authorizer.authorizer-uri}"
    authorizer-credentials = "${module.authorizer.authorizer-credentials}"
  })}"
}
```

3. ensure any operations to be protected reference the `security` definition; for example:

```json
...

"paths": {
  "/hello": {
      "get": {
        "security": [ { "basicAuth" : [] } ]
```

Alternatively, in YAML:

```yaml
...

paths:
  /hello:
    get:
      security:
        - basicAuth: []
```

> This is a known limitation of AWS API Gateway, where security cannot be applied to the whole API, and must 
> be applied on a per-operation basis (sad).
> Read more about API Gateway limitations here:
> https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-known-issues.html
   
4. ensure that your Swagger specification includes the following statements at the top-level in the document:

```json
{
  "x-amazon-apigateway-api-key-source": "AUTHORIZER",
  "securityDefinitions": {
    "basicAuth": {
      "type": "apiKey",
      "name": "Authorization",
      "in": "header",
      "x-amazon-apigateway-authtype": "custom",
      "x-amazon-apigateway-authorizer": {
        "type": "token",
        "authorizerUri": "${authorizer-uri}",
        "authorizerCredentials": "${authorizer-credentials}",
        "identityValidationExpression": "^x-[a-z]+",
        "authorizerResultTtlInSeconds": 300
      }
    }
  },
  "responses": {
    "UnauthorizedError": {
      "description": "Authentication information is missing or invalid",
      "headers": {
        "WWW_Authenticate": {
          "type": "string"
        }
      }
    }
  },
  "x-amazon-apigateway-gateway-responses": {
    "UNAUTHORIZED": {
      "statusCode": "401",
      "responseParameters": {
        "gatewayresponse.header.WWW-Authenticate": "'Basic'"
      },
      "responseTemplates": {
        "application/json": "{\"message\": \"$context.error.messageString\" }"
      }
    }
  }
}
```

Alternatively, the statements above, in YAML:

```yaml
x-amazon-apigateway-api-key-source: "AUTHORIZER"
securityDefinitions:
  basicAuth:
    type: apiKey
    name: Authorization
    in: header
    x-amazon-apigateway-authtype: "custom"
    x-amazon-apigateway-authorizer:
      type: token
      authorizerUri: "${authorizer-uri}"
      authorizerCredentials: "${authorizer-credentials}"
      identityValidationExpression: "^x-[a-z]+"
      authorizerResultTtlInSeconds: 300
responses:
  UnauthorizedError:
    description: Authentication information is missing or invalid
    headers:
      WWW_Authenticate:
        type: string
x-amazon-apigateway-gateway-responses:
  UNAUTHORIZED:
    statusCode: '401'
    responseParameters:
      gatewayresponse.header.WWW-Authenticate: "'Basic'"
    responseTemplates:
      application/json: '{"message": "$context.error.messageString" }'
```

### Without Swagger

If you *aren't* using Swagger:

1. import the module, and set the `api-id` in the module configuration to the ID of your AWS API Gateway Rest API; for example:

```terraform
module "authorizer" {
  source  = "git::git@github.com:khalidx/auth.git//basic/terraform?ref=v1.0.0"
  api-id = "${aws_api_gateway_rest_api.api.id}"
}
```

2. ensure that your `aws_api_gateway_rest_api` resource has the `api_key_source` field; for example:

```terraform
resource "aws_api_gateway_rest_api" "api" {
  ...

  api_key_source = "${module.authorizer.api-key-source}"
}
```

3. ensure that any `aws_api_gateway_method` resources in your `terraform` configuration have the proper authorizer-related fields; for example:

```terraform
resource "aws_api_gateway_method" "example-method" {
  ...

  authorization    = "${module.authorizer.authorization}"
  authorizer_id    = "${module.authorizer.authorizer-id}"
  api_key_required = "${module.authorizer.api-key-required}"
}
```

## Support

Open a GitHub issue to ask a question, report a bug, raise a concern, or request a new feature.
