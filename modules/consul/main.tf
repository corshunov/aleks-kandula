### CONSUL LOAD BALANCER
resource "aws_lb" "consul" {
  name                        = "consul-lb"
  internal                    = false
  load_balancer_type          = "application"
  subnets                     = var.public_subnet_ids
  security_groups             = [aws_security_group.consul.id]
}

resource "aws_lb_listener" "consul" {
  load_balancer_arn = aws_lb.consul.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul.arn
  }
}

resource "aws_lb_target_group" "consul" {
  name = "consul"
  port = 8500
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    enabled = true
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "consul" {
  count            = length(aws_instance.consul_server)
  target_group_arn = aws_lb_target_group.consul.id
  target_id        = aws_instance.consul_server.*.id[count.index]
  port             = 8500
}


### CONSUL SERVERS
data "template_file" "consul_server" {
  count    = var.servers
  template = file("${path.module}/consul.sh.tpl")

  vars = {
    consul_version = var.consul_version
    config = <<EOF
      "node_name": "consul-server-${count.index+1}",
      "server": true,
      "bootstrap_expect": 3,
      "ui": true,
      "client_addr": "0.0.0.0"
    EOF
  }
}

resource "aws_instance" "consul_server" {
  count                  = var.servers
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index % 2] 
  vpc_security_group_ids = [aws_security_group.consul.id]
  user_data              = element(data.template_file.consul_server.*.rendered, count.index)
  iam_instance_profile   = aws_iam_instance_profile.consul.name

  tags = {
    Name = "Consul Server ${count.index+1}"
    consul_server = "true"
  }
}

resource "aws_security_group" "consul" {
  name   = "consul"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "consul_ssh_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_all_inside_ingress" {
  type        = "ingress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  self        = true
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_ui_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 8500
  to_port     = 8500
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_http_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_all_egress" {
  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.consul.id
}

resource "aws_iam_role" "consul" {
  name               = "consul"
  assume_role_policy = file("${path.module}/assume-role.json")
}

resource "aws_iam_policy" "consul" {
  name        = "consul"
  policy      = file("${path.module}/describe-instances.json")
}

resource "aws_iam_policy_attachment" "consul" {
  name       = "consul"
  roles      = [aws_iam_role.consul.name]
  policy_arn = aws_iam_policy.consul.arn
}

resource "aws_iam_instance_profile" "consul" {
  name  = "consul"
  role = aws_iam_role.consul.name
}
