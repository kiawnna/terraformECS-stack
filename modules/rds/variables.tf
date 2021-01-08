variable "region" {
  type = string
  default = "us-east-1"
}
variable "app_name" {
  type = string
  default = "aleidy"
}
variable "environment" {
  type = string
  default = "dev"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "instance_type" {
    type = string
    default = "db.t3.small"
}
variable "writer_count" {
    type = number
    default = 1
}