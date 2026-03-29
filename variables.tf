variable "environment" {
  description = "Environment name, e.g., dev or prod"
  type        = string
}

variable "location" {
  description = "Azure region to deploy"
  type        = string
  default     = "westeurope"
}