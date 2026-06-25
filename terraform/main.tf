provider "aws" {
  region = var.aws_region
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-nginx-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach SSM policy (lets you manage EC2 without needing SSH keys)
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Instance profile (links IAM role to EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-nginx-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Restrict this to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "nginx_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"        # Free tier eligible
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from Terraform + NGINX!</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "nginx-app-server"
  }
}
