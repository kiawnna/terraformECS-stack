variable "hosted_zone_id" {
  type = string
}
variable "record_type" {
  type = string
  default = "A"
}
variable "lb_dns_name" {
  type = string
}
variable "subdomain" {
  type = string
}