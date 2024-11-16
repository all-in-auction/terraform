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

resource "aws_security_group" "gateway_sg" {
  name        = "kafka-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

