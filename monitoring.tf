resource "aws_instance" "monitoring-instance" {
  ami           = "ami-040c33c6a51fd5d96"
  instance_type = "t3.small"
  key_name      = "auction_key"

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update
            sudo apt upgrade -y
            sudo apt install -y curl apt-transport-https ca-certificates software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
            EOF
  
  tags = {
    Name = "monitoring-instance"
  }

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
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
