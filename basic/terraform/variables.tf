variable "name" {
  description = "The (optional) name to use for prefixing resources, resource tags, and the parameter store namespace."
  type = "string"
  default = "authorizer-basic"
}

variable "permissions-boundary-for-roles" {
  description = "The (optional) permissions boundary to use when creating IAM roles."
  type = "string"
  default = ""
}
