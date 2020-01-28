
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
  cidr_block  = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags  = {
    Name = var.name
  }
}

# Create security group for app_subnet (public)
resource "aws_security_group" "app_security_group" {
  description = "Allow TLS inbound traffic"
  vpc_id  = aws_vpc.app_vpc.id
  tags  = {
    Name = var.name
    }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_block = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_block     = ["0.0.0.0/0"]
  }
}

# Create security group for app_subnet (public)
resource "aws_security_group" "private_security_group" {
  description = "Allow TLS inbound traffic"
  vpc_id  = aws_vpc.app_vpc.id
  tags  = {
    Name = var.name
    }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block = [aws_subnet.app_subnet.cidr_block]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_block = [aws_subnet.app_subnet.cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_block     = ["0.0.0.0/0"]
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

  route {
    cidr_block = "0.0.0.0/0"
  }

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
