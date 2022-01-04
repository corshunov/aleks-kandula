terraform {
  required_version = ">= 0.12"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.7.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.68.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }

  backend "s3" {
    bucket  = "aleks-terraform"
    key     = "Kandula_State_Development"
    region  = "us-east-1"
  }
}

provider "aws" {
  region  = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "kandula"
    }
  }
}

data "aws_ami" "ubuntu_18" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "kandula_vpc" {
  source                    = "./../../modules/vpc"
  vpc_cidr                  = var.vpc_cidr
  public_cidrs              = var.vpc_public_cidrs
  private_cidrs             = var.vpc_private_cidrs
  ami_id                    = data.aws_ami.ubuntu_18.id
  key_name                  = var.key_name
}

module "kandula_jenkins" {
  source                    = "./../../modules/jenkins"
  vpc_id                    = module.kandula_vpc.vpc_id
  public_subnet_ids         = module.kandula_vpc.public_subnet_ids
  private_subnet_ids        = module.kandula_vpc.private_subnet_ids
  ami_id                    = data.aws_ami.ubuntu_18.id
  key_name                  = var.key_name
}

module "kandula_consul" {
  source                    = "./../../modules/consul"
  consul_version            = var.consul_version
  servers                   = var.consul_num_servers
  ami_id                    = data.aws_ami.ubuntu_18.id
  key_name                  = var.key_name
  public_subnet_ids         = module.kandula_vpc.public_subnet_ids
  private_subnet_ids        = module.kandula_vpc.private_subnet_ids
  vpc_id                    = module.kandula_vpc.vpc_id
}

module "kandula_eks" {
  source                    = "./../../modules/eks"
  kubernetes_version        = var.kubernetes_version
  vpc_id                    = module.kandula_vpc.vpc_id
  private_subnet_ids        = module.kandula_vpc.private_subnet_ids
  jenkins_role_arn          = module.kandula_jenkins.jenkins_role_arn
}
