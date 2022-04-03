
# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "Terra_demo"
  }
}

# VPC/subnet
resource "aws_subnet" "terra_subnet_public" {
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terra_001_public"
  }
}

resource "aws_subnet" "terra_subnet_private" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Terra_002_private"
  }
}

# VPC/gateway
resource "aws_internet_gateway" "terra_gateway" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "Terra_gateway"
  }
}

resource "aws_eip" "terra_ip" {
  vpc = true
  tags = {
    Name = "Terra_ip"
    Env  = "dev"
  }
}

resource "aws_nat_gateway" "terra" {
  allocation_id = aws_eip.terra_ip.id
  subnet_id     = aws_subnet.terra_subnet_public.id

  tags = {
    Name = "Terra_gw_NAT"
  }
}

# VPC/route
resource "aws_route_table" "terra_rt_public" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.terra_gateway.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_gateway.id
  }

  tags = {
    Name = "terra_rt_public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.terra_subnet_public.id
  route_table_id = aws_route_table.terra_rt_public.id
}

resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.terra_vpc.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terra.id
  }

  tags = {
    Name = "terra_rt_private"
  }
}

# VPC/Security groups

resource "aws_security_group" "terra_dmz" {
  name        = "terra_dmz"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    description = "HTTP from world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "HTTPS from world"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "SSH from world"
    from_port   = var.bastion_ssh_port
    to_port     = var.bastion_ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terra_dmz"
  }
}

resource "aws_security_group" "terra_private" {
  name        = "terra_private"
  description = "Allow inner network traffic"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.terra_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terra_private"
  }
}
