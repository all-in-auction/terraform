resource "aws_vpc" "cluster_vpc" {
  tags = {
    Name = "ecs-vpc-${var.env_suffix}"
  }
  cidr_block = "10.30.0.0/16"
}

data "aws_availability_zones" "available" {

}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.cluster_vpc.id
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.cluster_vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "ecs-private-subnet-${var.env_suffix}"
  }
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.cluster_vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.cluster_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-public-subnet-${var.env_suffix}"
  }
}

resource "aws_internet_gateway" "cluster_igw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "ecs-igw-${var.env_suffix}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id          = aws_vpc.cluster_vpc.main_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.cluster_igw.id
}

resource "aws_instance" "nat_instance" {
  ami           = "ami-0e0ce674db551c1a5"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name      = "auction_key"

  tags = {
    Name = "nat-instance-${var.env_suffix}"
  }

  vpc_security_group_ids = [aws_security_group.nat_instance_sg.id]
}

resource "aws_security_group" "nat_instance_sg" {
  name        = "nat-instance-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_private_to_nat_instance" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nat_instance_sg.id 
  cidr_blocks       = aws_subnet.private[*].cidr_block
}

resource "aws_security_group_rule" "allow_tcp_to_nat_instance" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nat_instance_sg.id 
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_eip" "nat_eip" {
  instance = aws_instance.nat_instance.id
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    instance_id    = aws_instance.nat_instance.id
  }

  tags = {
    Name = "private-route-table-${var.env_suffix}"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster_igw.id
  }

  tags = {
    Name = "ecs-route-table-${var.env_suffix}"
  }
}

resource "aws_route_table_association" "to-public" {
  count = length(aws_subnet.public)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_route.*.id, count.index)
}

resource "aws_route_table_association" "to-private" {
  count = length(aws_subnet.private)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
}