
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