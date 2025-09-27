terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Choose AZs, excluding us-east-1e (where t3.medium failed for you)
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  good_azs = [for az in data.aws_availability_zones.available.names : az if az != "us-east-1e"]
  az1      = local.good_azs[0]
  az2      = length(local.good_azs) > 1 ? local.good_azs[1] : local.good_azs[0]
}

# --- Networking: clean VPC with 2 public subnets ---
resource "aws_vpc" "mag" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "mag-vpc" }
}

resource "aws_internet_gateway" "mag" {
  vpc_id = aws_vpc.mag.id
  tags   = { Name = "mag-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mag.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mag.id
  }
  tags = { Name = "mag-rt-public" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.mag.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = true
  tags                    = { Name = "mag-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.mag.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = local.az2
  map_public_ip_on_launch = true
  tags                    = { Name = "mag-public-b" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# --- AMI: Ubuntu 22.04 (Canonical) ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- EC2 Runner ---
locals {
  runner_subnet_id = aws_subnet.public_a.id
}

resource "aws_instance" "runner" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.runner_subnet_id
  vpc_security_group_ids      = [aws_security_group.mag_sg.id]
  associate_public_ip_address = true

  # Use existing key if provided, else the generated one (keys.tf)
  key_name = aws_key_pair.mag_key.key_name



  # Join user_data path at use site
  user_data = file("${path.module}/${var.user_data_path}")

  tags = { Name = "mag-runner" }
}
