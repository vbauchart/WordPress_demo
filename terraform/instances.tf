# KEYS
variable "ami_image" {
  type    = string
  default = "ami-0245697ee3e07e755"
}

resource "aws_key_pair" "wp_key" {
  key_name   = "wordpress_key"
  public_key = file("${var.ssh_key_file}.pub")
}

# EFS Single AZ
resource "aws_efs_file_system" "web_content" {
  creation_token         = "web_content"
  encrypted              = true
  availability_zone_name = "eu-west-3a"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "web_content"
  }
}

resource "aws_efs_mount_target" "private_subnet" {
  file_system_id = aws_efs_file_system.web_content.id
  subnet_id      = aws_subnet.wordpress_private.id
  security_groups = [aws_security_group.wordpress_nfs.id]
}

#EC2 instances
resource "aws_instance" "proxy" {
  ami                    = var.ami_image
  instance_type          = "t2.micro"
  key_name               = "wordpress_key"
  subnet_id              = aws_subnet.wordpress_public.id
  vpc_security_group_ids = [aws_security_group.wordpress_public.id]

  tags = {
    Name = "wordpress_proxy"
  }
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = var.ami_image
  instance_type          = "t2.micro"
  key_name               = "wordpress_key"
  subnet_id              = aws_subnet.wordpress_private.id
  vpc_security_group_ids = [aws_security_group.wordpress_web.id]

  tags = {
    Name = "wordpress_web_${count.index}"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ami_image
  instance_type          = "t2.micro"
  key_name               = "wordpress_key"
  subnet_id              = aws_subnet.wordpress_private.id
  vpc_security_group_ids = [aws_security_group.wordpress_db.id]

  tags = {
    Name = "wordpress_db"
  }
}
