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