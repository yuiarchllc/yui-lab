module "alb_app" {
  source       = "../modules/alb"
  name         = "${local.general.service_name}-app"
  idle_timeout = local.alb.idle_timeout
  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
  ]
  security_groups = [
    aws_security_group.alb.id,
  ]
  certificate_arn   = module.acm_alb_app.arn
  vpc_id            = aws_vpc.this.id
  target_type       = "instance"
  health_check_path = "/app/"
}

module "alb_api" {
  source       = "../modules/alb"
  name         = "${local.general.service_name}-api"
  idle_timeout = local.alb.idle_timeout
  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
  ]
  security_groups = [
    aws_security_group.alb.id,
  ]
  certificate_arn   = module.acm_alb_api.arn
  vpc_id            = aws_vpc.this.id
  target_type       = "ip"
  health_check_path = "/api/"
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = module.alb_app.target_group_arn
  target_id        = aws_instance.this.id
  port             = 80
}