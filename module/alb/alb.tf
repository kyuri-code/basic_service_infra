#####################################################
## ALB
#####################################################
### ALB For Green/Blue Deployment
resource "aws_alb" "this" {
  name               = "${local.project_prefix}-alb"
  internal           = true # Private Subnetにあるコンテナに向けたALBのため、内部用のALBにする。
  load_balancer_type = "application"
  subnets = [
    var.subnet_backend_1a,
  ]
  security_groups = [
    aws_security_group.allow_tls_alb.id,
  ]

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-alb" }
  )
}

#####################################################
## Listener
#####################################################
### ALB Test Listener For 80 Port
resource "aws_alb_listener" "listener_8080" {
  load_balancer_arn = aws_alb.this.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }
}

#####################################################
## Target Group
#####################################################
### Target Group For Blue Deployment
resource "aws_alb_target_group" "this" {
  name                 = "${local.project_prefix}-alb-tg"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = "10"

  health_check {
    protocol            = "HTTP"
    port                = 8080
    path                = "/api/tasks/healthcheck"
    matcher             = "200"
    timeout             = "5"
    interval            = "10"
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
  }
}

#####################################################
## Security Group For Load Balancer 
#####################################################
resource "aws_security_group" "allow_tls_alb" {
  name        = "allow_tls__alb"
  description = "Allow TLS outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-alb-egress-internal" }
  )
}

### Egress Rule For Allowing TLS outboud traffic
resource "aws_vpc_security_group_egress_rule" "allow_any_traffic" {
  security_group_id = aws_security_group.allow_tls_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

### Ingress Rule For Allowing TLS outboud traffic
resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.allow_tls_alb.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}