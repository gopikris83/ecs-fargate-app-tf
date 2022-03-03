
output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}

output "private-subnet" {
  value = { for az, s in aws_subnet.private_subnet : az => s.id }
}

output "public-subnet" {
  value = { for az, s in aws_subnet.public_subnet : az => s.id }
}

output "albsgid" {
  value = aws_security_group.alb-sg.id
}

output "ecssgid" {
  value = aws_security_group.ecs_sg.id
}