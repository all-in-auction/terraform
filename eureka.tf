resource "aws_instance" "eureka-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t2.micro"
  key_name      = "auction_key"

  tags = {
    Name = "eureka-instance"
  }

  vpc_security_group_ids = [aws_security_group.eureka_sg.id]
  subnet_id = aws_subnet.public[0].id
}

resource "aws_security_group" "eureka_sg" {
  name        = "eureka-sg"
  vpc_id      = aws_vpc.cluster_vpc.id
}

resource "aws_security_group_rule" "egress_rule_eureka" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eureka_sg.id 
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ecs_to_eureka" {
  type              = "ingress"
  from_port         = 8761
  to_port           = 8761
  protocol          = "tcp"
  security_group_id = aws_security_group.eureka_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_gateway_to_eureka" {
  type              = "ingress"
  from_port         = 8761
  to_port           = 8761
  protocol          = "tcp"
  security_group_id = aws_security_group.eureka_sg.id 
  source_security_group_id = aws_security_group.gateway_sg.id
}

resource "aws_security_group_rule" "allow_tcp_to_eureka" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eureka_sg.id 
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_dashboard_to_eureka" {
  type              = "ingress"
  from_port         = 8761
  to_port           = 8761
  protocol          = "tcp"
  security_group_id = aws_security_group.eureka_sg.id 
  cidr_blocks       = ["0.0.0.0/0"]
}