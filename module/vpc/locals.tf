locals {
  project_prefix         = "study-basic-service"
  az_1a                  = "ap-northeast-3a"
  az_1c                  = "ap-northeast-3c"
  cidr_block_frontend    = "10.0.1.0/24"
  cidr_block_backend_1a  = "10.0.8.0/24"
  cidr_block_backend_1c  = "10.0.9.0/24"
  cidr_block_database_1a = "10.0.16.0/24"
  cidr_block_database_1c = "10.0.17.0/24"
  cidr_block_endpoint    = "10.0.254.0/24"
}