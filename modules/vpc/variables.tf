variable "vpc_cidr" {
  type        = string
}

variable "public_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type = string
}
