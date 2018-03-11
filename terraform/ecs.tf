resource "aws_ecr_repository" "main" {
  name = "insurgency_server-registry"
}

resource "aws_ecs_cluster" "main" {
  name = "InsurgencyServer-Cluster"
}

resource "aws_ecs_task_definition" "main" {
  family = "InsurgencyServer-Task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"

  # This is required to use images from ECR
  execution_role_arn = "${aws_iam_role.ecs_task_execution.arn}"

  # Docker settings for launching this container. This is similar to what
  # docker-compose does, but in a way that maps to AWS ECS orchestration engine.
  # Refer to Container Definitions, available at: 
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  container_definitions = <<DEFINITION
[
  {
    "name": "InsurgencyServer-Container",
    "image": "${aws_ecr_repository.main.repository_url}",
    "memory": 1024,
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 27015,
        "protocol": "udp"
      },
      {
        "containerPort": 27015,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.insurgency_server.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "InsurgencyServer"
      }
    },
    "environment": [
      {
        "name": "MAPNAME",
        "value": "${var.game_mapname}"
      },
      {
        "name": "SV_PASSWORD",
        "value": "${var.game_sv_password}"
      },
      {
        "name": "RCON_PASSWORD",
        "value": "${var.game_rcon_password}"
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name = "InsurgencyServer-Service"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.main.arn}"
  launch_type = "FARGATE"
  desired_count = 0

  network_configuration {
    security_groups = [
      "${aws_default_security_group.default.id}",
      "${aws_security_group.allow_server_traffic_from_internet.id}"
    ]
    subnets = ["${aws_subnet.main.id}"]
    assign_public_ip = true
  }
}
