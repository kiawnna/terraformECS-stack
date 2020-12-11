resource "aws_autoscaling_group" "bar" {
vpc_zone_identifier = [var.subnet_id]
desired_capacity = var.desired_capacity
max_size = var.max_size
min_size = var.min_size
//target_group_arns = var.target_group_arns
launch_configuration    = var.launch_config_id
}



