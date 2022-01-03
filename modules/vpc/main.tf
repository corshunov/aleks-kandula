### DATA
data "aws_availability_zones" "available" {}


### VIRTUAL PRIVATE CLOUD
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  map_public_ip_on_launch = true
  count                   = length(var.public_cidrs)
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "private" {
  map_public_ip_on_launch = false
  count                   = length(var.private_cidrs)
  cidr_block              = var.private_cidrs[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.vpc.id
}

resource "aws_eip" "nat_eip" {
  count      = length(var.public_cidrs)
}

resource "aws_nat_gateway" "nat" {
  count             = length(var.public_cidrs)
  allocation_id     = aws_eip.nat_eip.*.id[count.index]
  subnet_id         = aws_subnet.public.*.id[count.index]
}

resource "aws_route_table" "public" {
  vpc_id                  = aws_vpc.vpc.id
}

resource "aws_route_table" "private" {
  count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.vpc.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "private" {
  count                  = length(var.private_cidrs)
  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_cidrs)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}


### BASTION SERVER
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.*.id[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  tags = {
    Name    = "Bastion Server"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "all_egress" {
  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}
