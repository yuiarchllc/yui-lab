resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.general.service_name}"
  retention_in_days = 7
}