# -----------------------------------------------------------
# Project: AWS Web Infrastructure
# Author: Brendo Gabriel
# -----------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

# --- VPC & Networking ---

resource "aws_vpc" "minha_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Minha-VPC-Lab"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.minha_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-Publica"
  }
}

resource "aws_internet_gateway" "meu_igw" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "Meu-IGW"
  }
}

resource "aws_route_table" "minha_rota" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.meu_igw.id
  }

  tags = {
    Name = "Rota-Publica"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.minha_rota.id
}

# --- Security & Access ---

resource "aws_security_group" "sg_web" {
  name        = "SG-Web"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
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
}

# --- Compute ---

resource "aws_instance" "servidor_site" {
  ami           = "ami-0c7217cdde317cfec" # Amazon Linux 2023
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_publica.id
  vpc_security_group_ids = [aws_security_group.sg_web.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Infra via Terraform - Brendo Gabriel</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Servidor-Site-Terraform"
  }
}
