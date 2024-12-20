resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.cluster_vpc.id
  name = "lb-sg-${var.env_suffix}"

  ingress {
    from_port         = 80
    protocol          = "tcp"
    to_port           = 80
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  vpc_id = aws_vpc.cluster_vpc.id
  name = "ecs-tasks-sg-${var.env_suffix}"
}

resource "aws_security_group_rule" "egress_rule_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_tasks.id 
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_to_ecs" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_gRPC_to_ecs" {
  type              = "ingress"
  from_port         = 8085
  to_port           = 8085
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_redis_to_ecs" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.redis_sg.id
}

resource "aws_security_group_rule" "allow_rabbitmq_to_ecs" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.rabbitmq_sg.id
}

resource "aws_security_group_rule" "allow_mysql_to_ecs" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.mysql_sg.id
}

resource "aws_security_group_rule" "allow_mysql_to_ecs2" {
  type              = "ingress"
  from_port         = 3307
  to_port           = 3307
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.mysql_sg.id
}

resource "aws_security_group_rule" "allow_kafka1_to_ecs" {
  type              = "ingress"
  from_port         = 19092
  to_port           = 19092
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "allow_kafka2_to_ecs" {
  type              = "ingress"
  from_port         = 19093
  to_port           = 19093
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "allow_kafka3_to_ecs" {
  type              = "ingress"
  from_port         = 19094
  to_port           = 19094
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "allow_monitoring_logstash_to_ecs" {
  type              = "ingress"
  from_port         = 5044
  to_port           = 5044
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "allow_monitoring_es_to_ecs" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "allow_pmysql_to_ecs" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.point_mysql_sg.id
}

resource "aws_security_group_rule" "allow_eureka_to_ecs" {
  type              = "ingress"
  from_port         = 8761
  to_port           = 8761
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.eureka_sg.id
}

resource "aws_security_group_rule" "allow_gateway_to_ecs" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.gateway_sg.id
}