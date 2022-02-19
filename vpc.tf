###########################################################
# AWS VPC
# Create VPC for the ecsfargate-app deployment
###########################################################
resource "aws_vpc" "aws-vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

###########################################################
# AWS Internet Gateway
# Create Internet gateway for VPC resources to gain internet access
###########################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws-vpc.id
}


###########################################################
# AWS Nat Gateway
#Nat Gateway for private to public IP translation and routing traffic to internet
###########################################################
resource "aws_nat_gateway" "natgw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.tfeip.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_eip" "tfeip" {
  count = var.az_count
  vpc   = true
}

# Fetch AZ's in the current region
data "aws_availability_zones" "az" {
}

###########################################################
# AWS Private Subnet
# Create Private Subnet, each in differen AZ's
###########################################################
resource "aws_subnet" "private_subnet" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.aws-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  vpc_id            = aws_vpc.aws-vpc.id
}

resource "aws_route" "private-rt" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.private-route-table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
}

resource "aws_route_table" "private-route-table" {
  count  = var.az_count
  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_route_table_association" "private-rt-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}


###########################################################
# AWS Public Subnet
# Create Public Subnet, each in differen AZ's
###########################################################
resource "aws_subnet" "public_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.aws-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  vpc_id                  = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = true
}


resource "aws_route" "public-rt" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.pub-route-table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.igw.*.id, count.index)
}

resource "aws_route_table" "pub-route-table" {
  count  = var.az_count
  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_route_table_association" "pub-rt-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.pub-route-table.*.id, count.index)
}
