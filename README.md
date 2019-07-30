# auth

A collection of authentication and authorization implementations for AWS API Gateway.

[basic authentication scheme]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme
[HTTP authentication framework]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#The_general_HTTP_authentication_framework

- [auth](#auth)
  - [Basic](#basic)
  - [IAM](#iam)
  - [JWT](#jwt)

## Basic

This authentication strategy implements the [basic authentication scheme] of the [HTTP authentication framework].

This scheme transmits username and password credentials as a base64 encoded string, provided in the `Authorization` header.

**Important**: Since the username and password are passed over the network as clear text, the basic authentication scheme is not secure by itself. It must be used in conjunction with HTTPS/TLS.

This repository provides several sample implementations for your reference, as well as **a stand-alone terraform module** for this authentication strategy, which use and configure:

- API Gateway
- Lambda Authorizer
- Parameter Store

[Click here to browse to the ./basic/terraform/ directory](./basic/terraform), for a Terraform module that you can import into your infrastructure configuration.

[Click here to browse to the ./basic/terraform/examples/authorizer-with-swagger/ directory](./basic/terraform/examples/authorizer-with-swagger), for a sample implementation using Terraform.

[Click here to browse to the ./basic/serverless/ directory](./basic/serverless/), for a sample implementation using the Serverless Framework.

## IAM

This authentication strategy uses IAM and resource policies to control access to API Gateway resources and methods.

Coming soon.

## JWT

This authentication strategy uses a JWT bearer token to control access to API Gateway resources and methods.

Coming soon.
