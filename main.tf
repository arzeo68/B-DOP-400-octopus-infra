provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "project" : local.project_name,
      "organization" : local.organization_name
    }
  }
}

locals {
  vpc_cidr          = "10.16.0.0/16"
  project_name      = "octopus"
  organization_name = "epitech"
  instance_count    = 5
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.project_name}-vpc"
  cidr = local.vpc_cidr

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets      = [for i in range(0, 3) : cidrsubnet(local.vpc_cidr, 3, i)]
  private_subnet_names = [for i in range(0, 3) : "private-az${i + 1}"]
  private_route_table_tags = {
    "Name" : "${local.project_name}-private-rt"
  }

  public_subnets      = [for i in range(3, 6) : cidrsubnet(local.vpc_cidr, 3, i)]
  public_subnet_names = [for i in range(0, 3) : "public-az${i + 1}"]
  public_route_table_tags = {
    "Name" : "${local.project_name}-public-rt"
  }

  default_security_group_name = "${local.project_name}-default-sg"

  enable_nat_gateway = false
  single_nat_gateway = false
}

resource "aws_key_pair" "deployer" {
  key_name   = "${local.project_name}-key"
  public_key = var.public_key
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.0"

  count = local.instance_count

  name = "${local.project_name}-instance-${count.index + 1}"

  instance_type               = "t3.micro"
  associate_public_ip_address = true
  ami                         = "ami-0e8be3ef4b6a1f0fd" // debian 13

  key_name = aws_key_pair.deployer.id

  monitoring = false
  subnet_id  = element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets))

  security_group_ingress_rules = {
    "allow_ssh" = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    "allow_http" = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}