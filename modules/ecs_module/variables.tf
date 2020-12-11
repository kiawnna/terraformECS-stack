variable "cluster_name" {
  default = ""
}
variable "target_group_arn" {
  type = string
}
variable "container_name" {
  type = string
}
variable "container_port" {
  type = number
}
variable "image_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "launch-config-security-group" {
  type = string
}
variable "auto_scaling_group_arn" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "security_group" {
  type = string
}