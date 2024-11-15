resource "aws_instance" "kafka-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t3.small"
  key_name      = "auction_key"

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y docker
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            sudo service docker start
            sudo systemctl enable docker
            sudo yum install -y libxcrypt-compat
            EOF
  
  tags = {
    Name = "kafka-instance"
  }

  vpc_security_group_ids = [aws_security_group.kafka_sg.id]
  subnet_id = aws_subnet.private[0].id
}

resource "aws_security_group" "kafka_sg" {
  name        = "kafka-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ecs_to_kafka1" {
  type              = "ingress"
  from_port         = 19092
  to_port           = 19092
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_ecs_to_kafka2" {
  type              = "ingress"
  from_port         = 19093
  to_port           = 19093
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_ecs_to_kafka3" {
  type              = "ingress"
  from_port         = 19094
  to_port           = 19094
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_bastion_to_kafka" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.kafka_sg.id 
  source_security_group_id = aws_security_group.bastion_sg.id    
}

resource "aws_security_group_rule" "allow_nat_to_kafka" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.kafka_sg.id 
  source_security_group_id = aws_security_group.nat_instance_sg.id    
}

