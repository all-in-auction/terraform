resource "aws_instance" "gateway-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t2.micro"
  key_name      = "auction_key"

  tags = {
    Name = "gateway-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo systemctl enable docker
              EOF

  vpc_security_group_ids = [aws_security_group.gateway_sg.id]
  subnet_id = aws_subnet.public[0].id
}

resource "aws_lb_target_group_attachment" "gateway_tg" {
  target_group_arn = aws_lb_target_group.staging.arn
  target_id        = aws_instance.gateway-instance.id
  port             = 8080
}

resource "aws_security_group" "gateway_sg" {
  name        = "gateway-sg"
  vpc_id      = aws_vpc.cluster_vpc.id
}

resource "aws_security_group_rule" "egress_rule_gateway" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.gateway_sg.id 
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_to_gateway" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.gateway_sg.id 
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ecs_to_gateway" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.gateway_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}