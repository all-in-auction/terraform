[
  {
    "name": "${app_name}",
    "image": "${aws_ecr_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "staging-service",
        "awslogs-group": "awslogs-service-staging-${env_suffix}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ],
    "cpu": 2,
    "environment": [
      {
        "name": "PORT",
        "value": "${host_port}"
      },
      {
        "name": "PROD_DB_URL",
        "value": "${point_mysql_host}"
      },
      {
        "name": "PROD_DB_PASSWORD",
        "value": "${point_mysql_password}"
      },
      {
        "name": "PAYMENT_CLIENT_KEY",
        "value": "${payment_client_key}"
      },
      {
        "name": "PAYMENT_SECRET_KEY",
        "value": "${payment_secret_key}"
      },
      {
        "name": "SPRING_PROFILES_ACTIVE",
        "value": "prod"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "mountPoints": [],
    "memory": 512,
    "volumesFrom": []
  }
]