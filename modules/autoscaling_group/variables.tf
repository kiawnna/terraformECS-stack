

variable "desired_capacity" {
  type = number
  default = 1
}
variable "max_size" {
  type = number
  default = 1
}
variable "min_size" {
  type = number
  default = 1
}
variable "launch_config_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "target_group_arns" {
 type = list(string)
}