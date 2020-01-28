
# Configure a cloud provider
provider "aws" {
  region  = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block  = "10.0.0.0/16"
  tags  = {
    Name = var.name
  }
}

# Create a subnet - using this default as public
resource "aws_subnet" "app_subnet" {
  vpc_id  = aws_vpc.app_vpc.id
  cidr_block  = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags  = {
    Name = var.name
  }
}

# Create a subnet - private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id  = aws_vpc.app_vpc.id
  cidr_block  = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags  = {
    Name = var.name
  }
}

# Creating an internet gateway
resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name} - internet gateway"
  }
}

# Creating a route table with internet gateway
resource "aws_route_table" "app_route" {
  vpc_id  = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_gw.id
  }

  tags = {
    Name = "${var.name} - route (with internet)"
  }
}

# Creating a route table without internet gateway
resource "aws_route_table" "private_route" {
  vpc_id  = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name} - route (with no internet)"
  }
}

# Set route table associations for public subnet
resource "aws_route_table_association" "app_route_assoc" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route.id
}

# Set route table associations for private subnet
resource "aws_route_table_association" "private_route_assoc" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

# Create a NACL for app_subnet (public)
resource "aws_network_acl" "app_subnet_nacl" {
  vpc_id = aws_vpc.app_vpc.id
  subnet_ids = [aws_subnet.app_subnet.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "${var.name} - public subnet NACL"
  }
}

# Create a NACL for private_subnet
resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = aws_vpc.app_vpc.id
  subnet_ids = [aws_subnet.private_subnet.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = aws_subnet.app_subnet.cidr_block
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "${var.name} - public subnet NACL"
  }
}
