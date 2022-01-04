output "lb_dns_name" {
  value = aws_lb.jenkins.dns_name
}

output "jenkins_role_arn" {
  value = aws_iam_role.jenkins.arn
}
