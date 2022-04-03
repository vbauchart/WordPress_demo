# EC2
variable "ami_image" {
  type    = number
  default = 7710
}

resource "aws_key_pair" "terra_key" {
  key_name   = "terra_key"
  public_key = file("${var.ssh_key_file}.pub")
}

resource "aws_instance" "proxy" {
  ami                    = var.ami_image
  instance_type          = "t2.micro"
  key_name               = "terra_key"
  subnet_id              = aws_subnet.terra_subnet_public.id
  vpc_security_group_ids = [aws_security_group.terra_dmz.id]
  user_data              = <<EOF
#!/bin/sh
# change default ssh port on public host
sed -i "s/#Port .*/Port ${var.bastion_ssh_port}/" /etc/ssh/sshd_config
service sshd restart
EOF

  tags = {
    Name = "Terra_proxy"
  }
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = var.ami_image
  instance_type          = "t2.micro"
  key_name               = "terra_key"
  subnet_id              = aws_subnet.terra_subnet_private.id
  vpc_security_group_ids = [aws_security_group.terra_private.id]

  tags = {
    Name = "Terra_web_${count.index}"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ami_image
  instance_type          = "t2.micro"
  key_name               = "terra_key"
  subnet_id              = aws_subnet.terra_subnet_private.id
  vpc_security_group_ids = [aws_security_group.terra_private.id]

  tags = {
    Name = "Terra_db"
  }
}

