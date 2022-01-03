### JENKINS LOAD BALANCER
resource "aws_lb" "jenkins" {
  name                        = "jenkins-lb"
  internal                    = false
  load_balancer_type          = "application"
  subnets                     = var.public_subnet_ids
  security_groups             = [aws_security_group.jenkins_server.id]
}

resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.jenkins.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

resource "aws_lb_target_group" "jenkins" {
  name = "jenkins"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    enabled = true
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.id
  target_id = aws_instance.jenkins_server.id
  port = 80
}


### JENKINS SERVER (MASTER)
resource "aws_instance" "jenkins_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.jenkins_server.id]
  user_data              = local.server_user_data

  tags = {
    Name = "Jenkins Server"
  }
}

resource "aws_security_group" "jenkins_server" {
  name    = "jenkins_server"
  vpc_id  = var.vpc_id
}

resource "aws_security_group_rule" "server_tls_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_server.id
}

resource "aws_security_group_rule" "server_http_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_server.id
}

resource "aws_security_group_rule" "server_ssh_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_server.id
}

resource "aws_security_group_rule" "server_all_egress" {
  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_server.id
}


### JENKINS NODES (AGENTS)
resource "aws_instance" "jenkins_agents" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.jenkins_agent.id]
  user_data              = local.agent_user_data

  tags = {
    Name = "Jenkins Agent ${count.index+1}"
  }
}

resource "aws_security_group" "jenkins_agent" {
  name    = "jenkins_agent"
  vpc_id  = var.vpc_id
}

resource "aws_security_group_rule" "agent_tls_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_agent.id
}

resource "aws_security_group_rule" "agent_ssh_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_agent.id
}

resource "aws_security_group_rule" "agent_all_egress" {
  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_agent.id
}
