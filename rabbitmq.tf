resource "aws_instance" "rabbitmq-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t2.micro"
  key_name      = "auction_key"

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y docker
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            sudo service docker start
            sudo systemctl enable docker

            cat <<'EOT' >> rabbitmq-compose.yml
            services:
              rabbitmq1:
                image: countrym/rabbitmq-delayed-queue-ubuntu:latest
                container_name: rabbitmq1
                hostname: rabbitmq1
                environment:
                  - RABBITMQ_ERLANG_COOKIE=auctionCookie
                  - RABBITMQ_NODENAME=rabbit@rabbitmq1
                  - RABBITMQ_FEATURE_FLAGS=quorum_queue
                ports:
                  - 5672:5672
                  - 15672:15672
                networks:
                  - rabbitmq
                volumes:
                  - rabbitmq1-data:/var/lib/rabbitmq

              rabbitmq2:
                image: countrym/rabbitmq-delayed-queue-ubuntu:latest
                container_name: rabbitmq2
                hostname: rabbitmq2
                environment:
                  - RABBITMQ_ERLANG_COOKIE=auctionCookie
                  - RABBITMQ_NODENAME=rabbit@rabbitmq2
                  - RABBITMQ_FEATURE_FLAGS=quorum_queue
                ports:
                  - 5673:5672
                  - 15673:15672
                networks:
                  - rabbitmq
                depends_on:
                  - rabbitmq1
                volumes:
                  - rabbitmq2-data:/var/lib/rabbitmq

              rabbitmq3:
                image: countrym/rabbitmq-delayed-queue-ubuntu:latest
                container_name: rabbitmq3
                hostname: rabbitmq3
                environment:
                  - RABBITMQ_ERLANG_COOKIE=auctionCookie
                  - RABBITMQ_NODENAME=rabbit@rabbitmq3
                  - RABBITMQ_FEATURE_FLAGS=quorum_queue
                ports:
                  - 5674:5672
                  - 15674:15672
                networks:
                  - rabbitmq
                depends_on:
                  - rabbitmq1
                volumes:
                  - rabbitmq3-data:/var/lib/rabbitmq

            networks:
              rabbitmq:
                external: true

            volumes:
              rabbitmq1-data:
              rabbitmq2-data:
              rabbitmq3-data:
            EOT

            sudo docker-compose -f rabbitmq-compose.yml up -d
            EOF

  tags = {
    Name = "rabbitmq-instance"
  }

  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  subnet_id = aws_subnet.private[0].id
}

resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq-sg"
  description = "Allow Redis access"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ecs_to_rabbitmq" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  security_group_id = aws_security_group.rabbitmq_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_bastion_to_rabbitmq" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rabbitmq_sg.id 
  source_security_group_id = aws_security_group.bastion_sg.id    
}