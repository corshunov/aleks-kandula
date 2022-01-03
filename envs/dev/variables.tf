variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_public_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "key_name" {
  type    = string
  default = "terra"
}

variable "consul_version" {
  type    = string
  default = "1.8.5"
}

variable "consul_num_servers" {
  type    = number
  default = 3
}

variable "kubernetes_version" {
  type    = string
  default = "1.18"
}
