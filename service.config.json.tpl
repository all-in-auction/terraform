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
        "name": "S3_NAME",
        "value": "all-in-auction-bucket"
      },
      {
        "name": "S3_ACCESS",
        "value": "${aws_access_key_id}"
      },
      {
        "name": "S3_SECRET",
        "value": "${aws_secret_access_key}"
      },
      {
        "name": "JWT_SECRET_KEY",
        "value": "${jwt_secret_key}"
      },
      {
        "name": "RABBITMQ_HOST",
        "value": "${rabbitmq_host}"
      },
      {
        "name": "REDIS_HOST",
        "value": "${redis_host}"
      },
      {
        "name": "REDIS_PASSWORD",
        "value": "${redis_password}"
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
        "name": "LOGSTASH_HOST",
        "value": "${logstash_host}"
      },
      {
        "name": "LOGSTASH_PORT",
        "value": "5044"
      },
      {
        "name": "KAFKA_HOST",
        "value": "${kafka_host}"
      },
      {
        "name": "MASTER_DB_URL",
        "value": "jdbc:mysql://${mysql_host}:3306/auction_test"
      },
      {
        "name": "SLAVE_DB_URL",
        "value": "jdbc:mysql://${mysql_host}:3307/auction_test"
      },
      {
        "name": "MASTER_DB_PW",
        "value": "${master_db_pw}"
      },
      {
        "name": "SLAVE_DB_PW",
        "value": "${slave_db_pw}"
      },
      {
        "name": "ELASTICSEARCH_URIS",
        "value": "${elasticsearch_host}:9200"
      },
      {
        "name": "ELASTICSEARCH_USERNAME",
        "value": "${elasticsearch_username}"
      },
      {
        "name": "ELASTICSEARCH_PASSWORD",
        "value": "${elasticsearch_password}"
      },
      {
        "name": "SPRING_PROFILES_ACTIVE",
        "value": "prod"
      },
      {
        "name": "KAFKA_HOSTS",
        "value": "${kafka_host}:19092, ${kafka_host}:19093, ${kafka_host}:19094"
      },
      {
        "name": "EUREKA_HOST",
        "value": "${eureka_host}"
      },
      {
        "name": "ECS_CONTAINER_METADATA_URI_V4",
        "value": ""
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