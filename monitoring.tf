resource "aws_instance" "monitoring-instance" {
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
    Name = "monitoring-instance"
  }

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  subnet_id = aws_subnet.public[0].id
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ecs_to_monitoring_logstash" {
  type              = "ingress"
  from_port         = 5044
  to_port           = 5044
  protocol          = "tcp"
  security_group_id = aws_security_group.monitoring_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_ecs_to_monitoring_es" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.monitoring_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_bastion_to_monitoring" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id 
  source_security_group_id = aws_security_group.bastion_sg.id    
}

resource "aws_security_group_rule" "allow_tcp_to_monitoring" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id 
  cidr_blocks   = ["0.0.0.0/0"]    
}

resource "aws_security_group_rule" "allow_admin_to_monitoring_kibana" {
  type                     = "ingress"
  from_port                = 5601
  to_port                  = 5601
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id 
  cidr_blocks   = ["0.0.0.0/0"]    
}

resource "aws_security_group_rule" "allow_admin_to_monitoring_prometheus" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id 
  cidr_blocks   = ["0.0.0.0/0"]    
}

resource "aws_security_group_rule" "allow_admin_to_monitoring_grafana" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id 
  cidr_blocks   = ["0.0.0.0/0"]    
}
