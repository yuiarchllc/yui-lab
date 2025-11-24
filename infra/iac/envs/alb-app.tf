resource "aws_lb" "app" {
  name               = "${local.general.service_name}-app-lb"
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

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = module.acm_alb_app.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${local.general.service_name}-app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"
  health_check {
    interval            = 10
    path                = "/app/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.this.id
  port             = 80
}