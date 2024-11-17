resource "aws_instance" "gateway-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t3.small"
  key_name      = "auction_key"

  tags = {
    Name = "gateway-instance"
  }

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
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

resource "aws_security_group" "gateway_sg" {
  name        = "gateway-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.lb.id]
    cidr_blocks   = ["10.30.0.0/16"]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_tcp_to_gateway" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.gateway_sg.id 
  cidr_blocks = ["0.0.0.0/0"]
}