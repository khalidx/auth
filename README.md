# auth

A collection of authentication and authorization implementations for AWS API Gateway.

[basic authentication scheme]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme
[HTTP authentication framework]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#The_general_HTTP_authentication_framework

- [auth](#auth)
  - [To do](#to-do)
  - [Basic](#basic)
  - [IAM](#iam)
  - [JWT](#jwt)

## To do

- [ ] split out basic vs basic with api key
- [ ] deploy with serverless or deploy with terraform or cloudformation + aws one-click

## Basic

This authentication strategy implements the [basic authentication scheme] of the [HTTP authentication framework].

This scheme transmits username and password credentials as a base64 encoded string, provided in the `Authorization` header.

**Important**: Since the username and password are passed over the network as clear text, the basic authentication scheme is not secure by itself. It must be used in conjunction with HTTPS/TLS.

This repository provides a [sample implementation](./basic/README.md) for this authentication strategy.

Browse the `./basic/` directory for a sample implementation that uses:

- API Gateway
- Lambda Authorizer
- Lambda
- Parameter Store
- Terraform

## IAM

This authentication strategy uses IAM and resource policies to control access to API Gateway resources and methods.

Coming soon.

## JWT

This authentication strategy uses a JWT bearer token to control access to API Gateway resources and methods.

Coming soon.
