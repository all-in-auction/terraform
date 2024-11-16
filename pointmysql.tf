resource "aws_instance" "point-mysql-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t2.micro"
  key_name      = "auction_key"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "point-mysql-instance"
  }

  vpc_security_group_ids = [aws_security_group.point_mysql_sg.id]
  subnet_id = aws_subnet.private[0].id
}

resource "aws_security_group" "point_mysql_sg" {
  name        = "point-mysql-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ecs_to_pmysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.point_mysql_sg.id 
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_bastion_to_pmysql" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.point_mysql_sg.id 
  source_security_group_id = aws_security_group.bastion_sg.id    
}

resource "aws_security_group_rule" "allow_nat_to_pmysql" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.point_mysql_sg.id 
  source_security_group_id = aws_security_group.nat_instance_sg.id    
}