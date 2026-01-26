# -----------------------------------------------------------
# PROJETO: INFRAESTRUTURA AWS COM VPC CUSTOMIZADA
# AUTOR: BRENDO GABRIEL
# DATA: JANEIRO/2026
# -----------------------------------------------------------

# 1. PROVEDOR (Quem vai receber os comandos? A AWS)
provider "aws" {
  region = "us-east-1"
}

# 2. A VPC (O Terreno Cercado)
# Lógica: Criar rede 10.0.0.0/16
resource "aws_vpc" "minha_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Minha-VPC-Lab"
  }
}

# 3. A SUBNET (O Loteamento Público)
# Lógica: Criar rede 10.0.1.0/24 e habilitar IP Público automático
resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.minha_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true  # Aqui é o "Auto-assign Public IP"

  tags = {
    Name = "Subnet-Publica"
  }
}

# 4. INTERNET GATEWAY (O Portão da Rua)
# Lógica: Criar o portão e prender na VPC
resource "aws_internet_gateway" "meu_igw" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "Meu-IGW"
  }
}

# 5. ROUTE TABLE (A Placa de Trânsito)
# Lógica: Dizer que 0.0.0.0/0 vai para o IGW
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

# 6. ASSOCIAÇÃO DA ROTA (Colocar a placa na rua certa)
# Lógica: A subnet pública precisa usar a tabela de rotas que criamos
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.minha_rota.id
}

# 7. SECURITY GROUP (O Leão de Chácara)
# Lógica: Permitir porta 80 (HTTP) e 22 (SSH)
resource "aws_security_group" "sg_web" {
  name        = "SG-Web"
  description = "Liberar HTTP e SSH"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description = "HTTP de qualquer lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH de qualquer lugar"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra de saída: Liberar tudo (para o servidor baixar atualizações)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 8. EC2 INSTANCE (O Servidor)
# Lógica: Subir a t2.micro com o script de instalação
resource "aws_instance" "servidor_site" {
  ami           = "ami-0c7217cdde317cfec" # ID do Amazon Linux 2023 (us-east-1)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_publica.id
  vpc_security_group_ids = [aws_security_group.sg_web.id]

  # Aqui entra o seu Script Bash
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