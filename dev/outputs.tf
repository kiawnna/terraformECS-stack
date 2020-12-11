

output "security_group_ids" {
 value = module.ec2-security_group.security_group_id
}
output "target_group_arn" {
 value = module.target_group.target_group_arn
}
output "autoscaling_group_name" {
  value = module.autoscaling_group.autoscaling_group_name
}