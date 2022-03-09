resource "aws_autoscaling_group" "bar" {
name                = substr("${var.app_name}-${var.region}-${var.environment}-AutoscalingGroup", 0,32 )
vpc_zone_identifier = var.subnet_id
desired_capacity    = var.desired_capacity
max_size            = var.max_size
min_size            = var.min_size
//target_group_arns = var.target_group_arns
launch_configuration    = var.launch_config_id
    tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}





