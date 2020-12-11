variable "vpc_cidr_block" {
    type = string
    default = "10.200.0.0/16"
}
variable "public_subnet1_cidr_block" {
    type = string
    default = "10.200.0.0/24"
}
variable "public_subnet2_cidr_block" {
    type = string
    default = "10.200.1.0/24"
}
variable "private_subnet1_cidr_block" {
    type = string
    default = "10.200.2.0/24"
}
variable "app_name" {
    type = string
    default = "hello_world"
}
variable "region" {
    type = string
    default = "us-east-1"
}