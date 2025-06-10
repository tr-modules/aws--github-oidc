variable "thumbrint" {
  description = "AWS region"
  type        = list(string)
  default     = null
}

variable "allowed_repos" {
  description = "List of the repositories that has access to the OIDC"
  type        = list(string)
  default     = []
}

variable "policy_arn" {
  description = "policy attached to the OIDC"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix to be used in the created resources"
  type        = string
  default     = null
}