resource "aws_instance" "mysql-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t3.small"
  key_name      = "auction_key"

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