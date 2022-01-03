output "bastion_ip" {
  value = module.kandula_vpc.bastion_ip
}

output "jenkins_lb_dns" {
  value = module.kandula_jenkins.lb_dns_name
}

output "consul_lb_dns" {
  value = module.kandula_consul.lb_dns_name
}

output "eks_cluster_endpoint" {
  value = module.kandula_eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.kandula_eks.cluster_name
}

