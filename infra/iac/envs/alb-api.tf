resource "aws_lb" "api" {
  name               = "${local.general.service_name}-api-lb"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = local.alb.idle_timeout
  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
  ]
  security_groups = [
    aws_security_group.alb.id,
  ]
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = module.acm_alb_api.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name        = "${local.general.service_name}-api-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"
  health_check {
    interval            = 10
    path                = "/api/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}