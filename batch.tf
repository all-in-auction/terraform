resource "aws_instance" "batch-instance" {
  ami           = "ami-02c329a4b4aba6a48"
  instance_type = "t2.micro"
  key_name      = "auction_key"

  tags = {
    Name = "batch-instance"
  }

  vpc_security_group_ids = [aws_security_group.batch_sg.id]
  subnet_id = aws_subnet.private[0].id
}

resource "aws_security_group" "batch_sg" {
  name        = "batch-sg"
  vpc_id      = aws_vpc.cluster_vpc.id

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_redis_to_batch" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.batch_sg.id
  source_security_group_id = aws_security_group.redis_sg.id
}

resource "aws_security_group_rule" "allow_bastion_to_batch" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.batch_sg.id 
  source_security_group_id = aws_security_group.bastion_sg.id    
}

resource "aws_security_group_rule" "allow_nat_to_batch" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.batch_sg.id 
  source_security_group_id = aws_security_group.nat_instance_sg.id    
}

resource "aws_security_group_rule" "allow_mysql_to_batch" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.batch_sg.id 
  source_security_group_id = aws_security_group.mysql_sg.id    
}

resource "aws_security_group_rule" "allow_eureka_to_batch" {
  type                     = "ingress"
  from_port                = 8761
  to_port                  = 8761
  protocol                 = "tcp"
  security_group_id        = aws_security_group.batch_sg.id 
  source_security_group_id = aws_security_group.eureka_sg.id    
}