output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "subnet_frontend" {
  value = aws_subnet.frontend.id
}

output "subnet_backend_1a" {
  value = aws_subnet.backend_1a.id
}

output "subnet_backend_1c" {
  value = aws_subnet.backend_1c.id
}

output "database_1a" {
  value = aws_subnet.database_1a.id
}

output "database_1c" {
  value = aws_subnet.database_1c.id
}