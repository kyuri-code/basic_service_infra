#####################################################
## VPC
#####################################################
resource "aws_vpc" "this" {
  assign_generated_ipv6_cidr_block     = "false"       // iPV6の利用可否
  cidr_block                           = "10.0.0.0/16" // VPC内で扱えるサブネットのCIDR 10.0.0.0 ~ 10.0.255.255までのサブネットの指定が可能。
  enable_dns_hostnames                 = "true"        // IPアドレスではなく、特定の名前をURLを使用することでアクセス可能。
  enable_dns_support                   = "true"        // DNSサーバのサポートを受けるか
  enable_network_address_usage_metrics = "false"       // VPC内のサブネットごとのIPアドレスの使用率をトラッキング。コスト増になるので、無効
  instance_tenancy                     = "default"     // 共有か占有か。共有 : 他の顧客とハードウェアを共有。

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-vpc" }
  )
}

#####################################################
## Subnet
#####################################################
### Public Subnet For Frontend
resource "aws_subnet" "frontend" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.cidr_block_frontend
  availability_zone       = local.az_1a
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-frontend" }
  )
}

### Private Subnet For Backend
resource "aws_subnet" "backend_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.cidr_block_backend_1a
  availability_zone       = local.az_1a
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-backend-1a" }
  )
}

resource "aws_subnet" "backend_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.cidr_block_backend_1c
  availability_zone       = local.az_1c
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-backend-1c" }
  )
}

### Private Subnet For Database
resource "aws_subnet" "database_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.cidr_block_database_1a
  availability_zone       = local.az_1a
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-database-1a" }
  )
}

resource "aws_subnet" "database_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.cidr_block_database_1c
  availability_zone       = local.az_1c
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-database-1c" }
  )
}

resource "aws_subnet" "endpoint" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.cidr_block_endpoint
  availability_zone       = local.az_1c
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-vpc-1a" }
  )
}

#####################################################
## Internet Gateway
#####################################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-igw" }
  )
}

#####################################################
## Nat Gateway
#####################################################
resource "aws_eip" "this" {
  count  = 1 // 作成するEIPの数
  domain = "vpc"

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-eip-1" }
  )
}
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.frontend.id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-natgateway" }
  )

  depends_on = [aws_internet_gateway.this]
}

#####################################################
## Route Table
#####################################################
### Internet Gateway宛てのルーティング
resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.project_prefix}-ngw-rt"
  })
}

resource "aws_route_table" "ngw" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.project_prefix}-igw-rt"
  })
}
### Frontendのルーティング
resource "aws_route_table_association" "frontend" {
  route_table_id = aws_route_table.igw.id
  subnet_id      = aws_subnet.frontend.id
}

### Backendのルーティング
resource "aws_route_table_association" "app_1a" {
  route_table_id = aws_route_table.ngw.id
  subnet_id      = aws_subnet.backend_1a.id
}

resource "aws_route_table_association" "app_1c" {
  route_table_id = aws_route_table.ngw.id
  subnet_id      = aws_subnet.backend_1c.id
}

#####################################################
## VPC Endpoint
#####################################################
# ssmのparameter storeにアクセスするためのEndpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.this.id
  subnet_ids          = [aws_subnet.endpoint.id]
  service_name        = "com.amazonaws.ap-northeast-3.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoint.id]

  policy = data.aws_iam_policy_document.ssm_endpoint_policy.json

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-ssm-vpc-endpoint" }
  )
}

#####################################################
## IAM Policy
#####################################################
data "aws_iam_policy_document" "ssm_endpoint_policy" {
  statement {
    effect  = "Allow"
    actions = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
  }
}

#####################################################
## Security Group
#####################################################
# Security Group For VPC Endpoint
resource "aws_security_group" "vpc_endpoint" {
  name        = "${local.project_prefix}-sg-ssm-endpoint"
  description = "Security Group For VPC Endpoint To SSM Of Basic Server Project"
  vpc_id      = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-sg-backend" }
  )
}

# Ingress Allow 443 Port
resource "aws_vpc_security_group_ingress_rule" "allow_443" {
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_ipv4         = aws_vpc.this.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Egress Allow Any Port
resource "aws_vpc_security_group_egress_rule" "outbound_any" {
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}