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
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "${local.general.region}"
          awslogs-stream-prefix = local.ecr.repos.api
        }
      }
    }
  ])
}

resource "aws_ecs_service" "php_app" {
  name            = "${local.general.service_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.php_app.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id,
    ]
    security_groups = [
      aws_security_group.ecs.id,
    ]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = module.alb_api.target_group_arn
    container_name   = local.ecr.repos.api
    container_port   = 80
  }
  depends_on = [module.alb_api]
}
