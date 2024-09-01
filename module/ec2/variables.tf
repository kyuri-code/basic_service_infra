variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "The ID of VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The Cidr Block of VPC"
  type        = string
}

variable "subnet_frontend" {
  description = "The Public Subnet For Frontend"
  type        = string
}

variable "subnet_backend_1a" {
  description = "The Private Subnet For Backend 1a"
  type        = string
}

variable "subnet_backend_1c" {
  description = "The Private Subnet For Backend 1c"
  type        = string
}