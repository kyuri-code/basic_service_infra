#####################################################
## Key Pair
#####################################################
resource "aws_key_pair" "deployer" {
  key_name   = local.key_name
  public_key = file(local.ssh_key_path)
}

#####################################################
## EC2
#####################################################
### aws instance
resource "aws_instance" "frontend" {
  ami             = local.ami
  instance_type   = local.instance_type
  subnet_id       = var.subnet_frontend
  security_groups = [aws_security_group.frontend.id]
  key_name        = aws_key_pair.deployer.key_name

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-frontend" }
  )
}

resource "aws_instance" "backend_1a" {
  ami             = local.ami
  instance_type   = local.instance_type
  subnet_id       = var.subnet_backend_1a
  security_groups = [aws_security_group.backend.id]
  key_name        = aws_key_pair.deployer.key_name

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-backend-3a" }
  )
}

# resource "aws_instance" "backend_1c" {
#   ami             = local.ami
#   instance_type   = local.instance_type_3c
#   subnet_id       = var.subnet_backend_1c
#   security_groups = [aws_security_group.backend.id]
#   key_name        = aws_key_pair.deployer.key_name

#   tags = merge(
#     var.common_tags,
#     { "Name" = "${local.project_prefix}-backend-3c" }
#   )
# }

#####################################################
## Security Group
#####################################################
# Security Group For Frontend
resource "aws_security_group" "frontend" {
  name        = "${local.project_prefix}-sg-frontend"
  description = "Security Group For Frontend Of Basic Server Project"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-sg-frontend" }
  )
}

# Ingress Allow 80 Port
resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = local.my_ip
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_frontend" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = local.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Egress
resource "aws_vpc_security_group_egress_rule" "allow_any_outbound_traffic_frontend" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group For Backend
resource "aws_security_group" "backend" {
  name        = "${local.project_prefix}-sg-backend"
  description = "Security Group For Backend Of Basic Server Project"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-sg-backend" }
  )
}

# Ingress Allow 8080 Port
resource "aws_vpc_security_group_ingress_rule" "allow_8080" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_backend" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Egress
resource "aws_vpc_security_group_egress_rule" "allow_any_outbound_traffic_backend" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}