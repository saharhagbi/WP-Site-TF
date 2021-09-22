# VPC
resource "aws_vpc" "wp-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "wp-vpc"
  }
}

# subnets
resource "aws_subnet" "privateSN" {
  vpc_id            = aws_vpc.wp-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "PrivateSN"
  }
}

resource "aws_subnet" "publicSN" {
  vpc_id                  = aws_vpc.wp-vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"

  tags = {
    Name = "PublicSN"
  }
}

# subnet group
resource "aws_db_subnet_group" "wp-subnet-db-group" {
  name       = "wp-subnet-db-group"
  subnet_ids = [aws_subnet.privateSN.id, aws_subnet.publicSN.id]
}

# gateways
resource "aws_internet_gateway" "igw-wp" {
  vpc_id = aws_vpc.wp-vpc.id
}

resource "aws_nat_gateway" "nat-gw-wp" {
  allocation_id = aws_eip.eip_wp.id
  subnet_id     = aws_subnet.publicSN.id
  depends_on = [
    aws_internet_gateway.igw-wp
  ]
}

resource "aws_eip" "eip_wp" {
  vpc = true
}

#route tables
resource "aws_default_route_table" "default-rt" {
  default_route_table_id = aws_vpc.wp-vpc.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-wp.id
  }

  tags = {
    Name = "DefaultRT"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.wp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-wp.id
  }

  tags = {
    Name = "PublicRT"
  }
}

# associate the public route table to public subnet
resource "aws_route_table_association" "publicRT_to_publicSN" {
  subnet_id      = aws_subnet.publicSN.id
  route_table_id = aws_route_table.publicRT.id
}

# security groups
resource "aws_security_group" "sg-publicSN-wp" {
  name        = "security-group-wp"
  description = "sg for the public subnet"
  vpc_id      = aws_vpc.wp-vpc.id

  dynamic "ingress" {
    for_each = var.sg-rules
    content {
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["protocol"]
      cidr_blocks      = ingress.value["cidr_blocks"]
      ipv6_cidr_blocks = ingress.value["ipv6_cidr_blocks"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-Public"
  }
}

resource "aws_security_group" "sg-db-wp" {
  name   = "security-group-db"
  vpc_id = aws_vpc.wp-vpc.id

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-publicSN-wp.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-DB"
  }
}