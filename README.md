# Projeto: Infraestrutura de Rede e Servidor Linux (AWS) 

## 📌 Visão Geral  
Este projeto provisiona uma infraestrutura completa na AWS utilizando **Terraform**. O objetivo é criar um ambiente de rede seguro e isolado (VPC) para hospedar um servidor web Apache.

## 🛠 Tecnologias Utilizadas
* **AWS** (VPC, EC2, Internet Gateway, Security Groups)
* **Terraform** (Infraestrutura como Código)
* **Linux/Bash** (Script de automação User Data)

## ⚙️ Arquitetura
1. **VPC Customizada:** Rede 10.0.0.0/16 para isolamento lógico.
2. **Subnet Pública:** Configurada com auto-assign IP para acesso web.
3. **Roteamento:** Internet Gateway e Route Table configurados manualmente.
4. **Segurança:** Security Group liberando apenas tráfego HTTP (80).
5. **Compute:** Instância EC2 t2.micro provisionada com script de instalação automática do Apache.

## 📸 Prova de Conceito (PoC)
![Resultado Final](Projeto%20VPC.png)
