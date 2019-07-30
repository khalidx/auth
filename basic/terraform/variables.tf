variable "api-id" {
  description = "The (required) ID for the AWS API Gateway Rest API to associate the Lambda Authorizer to."
  type        = "string"
}

variable "name" {
  description = "The (optional) name to use for prefixing resources, resource tags, and the parameter store namespace."
  type        = "string"
  default     = "authorizer-basic"
}

variable "swagger" {
  description = "The (optional) flag for conditionally creating resources that are not being managed in a Swagger configuration."
  type        = bool
  default     = false
}

variable "permissions-boundary-for-roles" {
  description = "The (optional) permissions boundary to use when creating IAM roles."
  type        = "string"
  default     = ""
}
