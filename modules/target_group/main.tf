resource "aws_lb_target_group" "My_lb_Ale" {
  name     = substr("${var.app_name}-${var.region}-${var.environment}-targetGroup", 0,32 )
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc
  target_type = "ip"


health_check {
 enabled           = true
 matcher           = "200-304"
 protocol          = "HTTP"
 path              = var.health_check_path
 timeout           = 30
 interval          = 31
 healthy_threshold = 2
}
depends_on = [var.load_balancer_arn]
}





