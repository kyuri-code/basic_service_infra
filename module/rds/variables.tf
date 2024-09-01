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

variable "database_1a" {
  description = "The Private Subnet For Database AZ 1a"
  type        = string
}

variable "database_1c" {
  description = "The Private Subnet For Database AZ 1c"
  type        = string
}

variable "db_name" {
  description = "The DB Name For RDS"
  type        = string
}

variable "db_master_username" {
  description = "The Master Username For RDS"
  type        = string
}

variable "db_master_password" {
  description = "The Master Password For RDS"
  type        = string
}