resource "aws_lb" "this" {
  name               = "${var.name}-lb"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = var.idle_timeout
  subnets            = var.subnets
  security_groups    = var.security_groups
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type
  health_check {
    interval            = 10
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}