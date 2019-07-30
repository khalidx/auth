# authorizer-basic

- [authorizer-basic](#authorizer-basic)
  - [Usage](#usage)

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

If you *are* using Swagger, set `swagger = true` in the module configuration, and ensure that your Swagger specification includes the following statements at the top-level in the document.

```json
{
  "securityDefinitions": {
    "basicAuth": {
      "type": "basic"
    }
  },
  "security": [
    {
      "basicAuth": []
    }
  ],
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
securityDefinitions:
  basicAuth:
    type: basic
security:
  - basicAuth: []
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

To see an example of this module fully imported and configured, browse the `./examples/authorizer-with-swagger/` directory.

The example deploys a sample API to AWS API Gateway that is properly configured to use the authorizer. Pay special attention to any `x-amazon-apigateway-` configurations in the `swagger.yaml` file as well as the comments in the well-documented `main.tf` file. Reading both documents in the example will help you understand how all the components fit and work together.

To deploy an example, browse into the directory for the example and run the following commands.

```sh
terraform init
terraform apply
```
