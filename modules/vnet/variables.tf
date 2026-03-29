variable "environment" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "location" {
  type        = string
}

variable "vnet_name" {
  type        = string
}

variable "address_space" {
  type        = list(string)
}

variable "subnets" {
  type        = map(string)
}

variable "resource_group_name" {
  type = string
}