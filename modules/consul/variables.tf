variable "consul_version" {
  type = string
}

variable "servers" {
  type = number
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}
