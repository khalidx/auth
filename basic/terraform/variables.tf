variable "name" {
  description = "The (optional) name to use for prefixing resources, resource tags, and the parameter store namespace."
  type        = "string"
  default     = "authorizer-basic"
}

variable "api-id" {
  description = "The (optional) ID for the AWS API Gateway Rest API, if the API is not being configured using Swagger, for conditionally creating resources that are not being managed in a Swagger configuration."
  type        = "string"
  default     = ""
}

variable "permissions-boundary-for-roles" {
  description = "The (optional) permissions boundary to use when creating IAM roles."
  type        = "string"
  default     = ""
}
