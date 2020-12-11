
variable "vpc_id" {
  type = string
}
variable "security_group_name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string

  }))

  default = []
}




variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
  }))
}
variable "sg_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    protocol    = number
    security_groups  = list(string)

  }))

  default = []
}