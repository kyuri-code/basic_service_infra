provider "aws" {
  region = local.region
}

terraform {
  required_providers {
    aws = {
      version = "~> 5.9.0"
    }
  }
}

module "vpc" {
  source      = "./module/vpc"
  common_tags = local.common_tags
}

module "ec2" {
  source            = "./module/ec2"
  common_tags       = local.common_tags
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  subnet_frontend   = module.vpc.subnet_frontend
  subnet_backend_1a = module.vpc.subnet_backend_1a
  subnet_backend_1c = module.vpc.subnet_backend_1c
}

module "ssm" {
  source      = "./module/ssm"
  common_tags = local.common_tags
}

module "rds" {
  source             = "./module/rds"
  common_tags        = local.common_tags
  database_1a        = module.vpc.database_1a
  database_1c        = module.vpc.database_1c
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  vpc_id             = module.vpc.vpc_id
  db_name            = module.ssm.db_name
  db_master_username = module.ssm.db_username
  db_master_password = module.ssm.db_password
}

module "alb" {
  source = "./module/alb"
  common_tags       = local.common_tags
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  subnet_frontend   = module.vpc.subnet_frontend
  subnet_backend_1a = module.vpc.subnet_backend_1a
  subnet_backend_1c = module.vpc.subnet_backend_1c
}

