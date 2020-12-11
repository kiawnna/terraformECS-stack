variable "target_group_name" {
  type = string
}
variable "protocol" {
  type = string
  default = "HTTP"
}
variable "port" {
  type = number
  default = 80
}
variable "vpc" {
  type = string
}
variable "health_check_path" {
  type = string
  default = "/"
}
variable "load_balancer_arn" {
  type = string
}