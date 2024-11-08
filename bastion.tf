resource "aws_instance" "bastion" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t2.micro"
  subnet_id       = aws_subnet.public[0].id
  key_name        = "gogo123"
  security_groups = [aws_security_group.bastion_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              yum install -y jq
              yum install -y ec2-instance-connect

              # Enable SSH Agent Forwarding
              echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
              echo "GatewayPorts yes" >> /etc/ssh/sshd_config
              service sshd restart
              EOF

  tags = {
    Name = "Bastion"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = aws_vpc.cluster_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["222.112.111.112/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}