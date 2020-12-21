variable "internal" {
  type = bool
  default = "false"
}
variable "load_balancer_type" {
  type = string
  default = "application"
}
variable "security_groups" {
  type = list(string)
}
variable "subnets" {
  type = list(string)
}
variable "port" {
  type = number
  default = 80
}
variable "protocol" {
  type = string
  default = "HTTP"
}
variable "target_group_arn" {
  type = string
}
variable "domain" {
  type = string
  default = "test1.aleidy.kiastests.com"
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "app_name" {
  type = string
  default = "Aleidy"
}
variable "environment" {
  type = string
  default = "dev"
}