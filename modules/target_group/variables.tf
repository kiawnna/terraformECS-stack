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