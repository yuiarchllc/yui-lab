resource "aws_ecs_cluster" "this" {
  name = "${local.general.service_name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${local.general.service_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "php_app" {
  family                   = "${local.general.service_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = local.ecr.repos.api
      image     = "${local.general.account_id}.dkr.ecr.${local.general.region}.amazonaws.com/${local.ecr.repos.api}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.general.service_name}"
          awslogs-region        = "${local.general.region}"
          awslogs-stream-prefix = local.ecr.repos.api
        }
      }
    }
  ])
}
