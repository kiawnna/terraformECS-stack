resource "aws_lb" "ALB" {
  name               = var.load_balancer_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
   name = "ALB"
   Deployment_Method = "production"
  }
}
resource "aws_lb_listener" "port-80-traffic" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}
resource "aws_lb_listener_rule" "port-80-rule" {
  listener_arn = aws_lb_listener.port-80-traffic.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }
}