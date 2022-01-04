variable "kubernetes_version" {
  type    = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "jenkins_role_arn" {
  type = string
}
