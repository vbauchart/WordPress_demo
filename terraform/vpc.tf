
# VPC
resource "aws_vpc" "wordpress" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "wordpress"
  }
}

# VPC/subnet
resource "aws_subnet" "wordpress_public" {
  vpc_id                  = aws_vpc.wordpress.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wordpress_public"
  }
}

resource "aws_subnet" "wordpress_private" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "wordpress_private"
  }
}

# VPC/gateway
resource "aws_internet_gateway" "wordpress" {
  vpc_id = aws_vpc.wordpress.id

  tags = {
    Name = "wordpress"
  }
}

resource "aws_eip" "wordpress_nat" {
  vpc = true
  tags = {
    Name = "wordpress_nat"
  }
}

resource "aws_nat_gateway" "wordpress" {
  allocation_id = aws_eip.wordpress_nat.id
  subnet_id     = aws_subnet.wordpress_public.id

  tags = {
    Name = "wordpress"
  }
}

# VPC/route
resource "aws_route_table" "wordpress_public" {
  vpc_id = aws_vpc.wordpress.id

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.wordpress.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress.id
  }

  tags = {
    Name = "wordpress_public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.wordpress_public.id
  route_table_id = aws_route_table.wordpress_public.id
}

resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.wordpress.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wordpress.id
  }

  tags = {
    Name = "wordpress_private"
  }
}

# VPC/Security groups
resource "aws_security_group" "wordpress_public" {
  name        = "wordpress_public"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description = "HTTP from world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TLS certificates not implemented
  # ingress {
  #   description = "HTTPS from world"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "SSH from world"
    from_port   = 22
    to_port     = 22
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
    Name = "wordpress_dmz"
  }
}

resource "aws_security_group" "wordpress_web" {
  name        = "wordpress_web"
  description = "Allow inner network traffic"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_public.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_public.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress_web"
  }
}

resource "aws_security_group" "wordpress_db" {
  name        = "wordpress_db"
  description = "Allow inner network traffic"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_public.cidr_block]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_private.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress_db"
  }
}
resource "aws_security_group" "wordpress_nfs" {
  name        = "wordpress_nfs"
  description = "Allow inner network traffic"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_private.cidr_block]
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_private.cidr_block]
  }

  tags = {
    Name = "wordpress_nfs"
  }
}
