#####################################################
## RDS Subnet Group
#####################################################
resource "aws_db_subnet_group" "this" {
  name       = "${local.project_prefix}-rds-subnet-group"
  subnet_ids = [var.database_1a, var.database_1c]

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-rds-subnet-group" }
  )
}

#####################################################
## RDS Instance
#####################################################
# RDS PostgreSQL Instance
resource "aws_db_instance" "this" {
  depends_on = [
    var.db_name,
    var.db_master_username,
    var.db_master_password
  ]
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = "postgres"
  engine_version         = "16.2"
  instance_class         = "db.t3.micro"
  identifier             = "${local.project_prefix}-rds-instance"
  db_name                = var.db_name
  username               = var.db_master_username
  password               = var.db_master_password
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-rds-instance" }
  )
}


#####################################################
## Security Group
#####################################################
# Security Group For Database
resource "aws_security_group" "database" {
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-sg-database" }
  )
}

# Ingress Allow 5432 Port
resource "aws_vpc_security_group_ingress_rule" "allow_5432" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

# Egress rule for RDS
resource "aws_vpc_security_group_egress_rule" "database_allow_any_outbound" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}