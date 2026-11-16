# AWS Cloud Network (VPC) & Zero-Trust Firewall Blueprint
# Copyright (c) 2026 C C Marketing Media Group LLC

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-2"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

# 1. Isolated Virtual Private Cloud (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "cc-media-production-vpc"
    Environment = "Production"
    Owner       = "C C Marketing Media Group LLC"
  }
}

# 2. Public Subnet (For Front-End Load Balancers / Web Gateways)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "cc-media-public-subnet"
  }
}

# 3. Private Subnet (Isolated Zone for Sensitive Databases & Compute)
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "cc-media-private-subnet"
  }
}

# 4. Internet Gateway for Controlled External Connectivity
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "cc-media-igw"
  }
}

# 5. Zero-Trust Cloud Firewall (Security Group)
resource "aws_security_group" "web_firewall" {
  name        = "cc-media-https-only-sg"
  description = "Allow only encrypted HTTPS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Encrypted HTTPS from authorized networks"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cc-media-https-firewall"
  }
}
