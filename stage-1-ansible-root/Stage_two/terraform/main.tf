resource "aws_security_group" "server_sg" {
  name_prefix = "server_sg-"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "server_sg"
  }
}

resource "aws_instance" "server1" {
  ami             = var.instance_ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.server_sg.name]

  tags = {
    Name = "server1"
  }
}

resource "aws_instance" "server2" {
  ami             = var.instance_ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.server_sg.name]

  tags = {
    Name = "server2"
  }
}

output "server1_public_ip" {
  description = "Public IP of the first EC2 instance"
  value       = aws_instance.server1.public_ip
}

output "server2_public_ip" {
  description = "Public IP of the second EC2 instance"
  value       = aws_instance.server2.public_ip
}