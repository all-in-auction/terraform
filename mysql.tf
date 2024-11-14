resource "aws_instance" "mysql-instance" {
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

            cat <<'EOT' >> docker-compose.yml
            version: '3.1'
            services:
              mysql-master:
                image: mysql:8.0
                container_name: mysql-master
                environment:
                  - MYSQL_ROOT_PASSWORD=1234
                ports:
                  - "3306:3306"
                command:
                  - "--server-id=1"
                  - "--log-bin=mysql-bin"
                volumes:
                  - master-data:/var/lib/mysql

              mysql-slave:
                image: mysql:8.0
                container_name: mysql-slave
                environment:
                  - MYSQL_ROOT_PASSWORD=1234
                ports:
                  - "3307:3306"
                command:
                  - "--server-id=2"
                  - "--log-bin=mysql-bin"
                  - "--replicate-do-db=auction_test"
                volumes:
                  - slave-data:/var/lib/mysql
                depends_on:
                  - mysql-master

            volumes:
              master-data:
              slave-data:
            EOT

            sudo docker-compose up -d
            EOF

  tags = {
    Name = "mysql-instance"
  }

  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  subnet_id = aws_subnet.private[0].id
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ecs_to_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.mysql_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_ecs_to_mysql2" {
  type              = "ingress"
  from_port         = 3307
  to_port           = 3307
  protocol          = "tcp"
  security_group_id = aws_security_group.mysql_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_bastion_to_mysql" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mysql_sg.id 
  source_security_group_id = aws_security_group.bastion_sg.id    
}

resource "aws_security_group_rule" "allow_nat_to_mysql" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.mysql_sg.id 
  source_security_group_id = aws_security_group.nat_instance_sg.id    
}

resource "aws_security_group_rule" "allow_batch_to_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mysql_sg.id 
  source_security_group_id = aws_security_group.batch_sg.id    
}