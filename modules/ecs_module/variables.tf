variable "cluster_name" {
  default = ""
}
variable "target_group_arn" {
  type = string
}
variable "container_name" {
  type = string
}
variable "container_image" {
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
variable "region" {
  type = string
  default = "us-east-1"
}
variable "app_name" {
  type = string
  default = "kia"
}
variable "environment" {
  type = string
  default = "dev"
}
//variable "host_path" {
//  type = string
//}
variable "volume_name" {
  type = string
  default = ""
}
//variable "file_system_id" {
//  type = string
//  default = null
//}
variable "root_directory" {
  type = string
  default = ""
}
//variable "efs_access_point" {
//  type = string
//  default = null
//}

variable "volumes" {
  description = "(Optional) A set of volume blocks that containers in your task may use"
  type = list(object({
    name      = string
    efs_volume_configuration = list(object({
      file_system_id          = string
      transit_encryption      = string
      transit_encryption_port = number
      authorization_config = list(object({
        access_point_id = string
        iam             = string
      }))
    }))
  }))
  default = []
}

// CLOSEST I THINK
//variable "volume" {
//  type = list(object({
//    volume_name = string
//    host_path = string
//    file_system_id = string
//    access_point_id = string
//    iam = string
//  }))
//  default = []
//}

variable "attach_efs_volume" {
  type = bool
  default = false
}


//variable "volumes" {
//  description = "(Optional) A set of volume blocks that containers in your task may use"
//  default = [{
//    name = null
//    host_path = null
//    file_system_id = null
//    access_point_id = null
//  }]
//}

//variable "efs_configs" {
//  description = "(Optional) A set of volume blocks that containers in your task may use"
//  type = list(object({
//    file_system_id          = string
//  }))
//  default = []
//}
//variable "auth_configs" {
//  type = list(object({
//        access_point_id = string
//        iam             = string
//      }))
//  default = []

//  volumes = [{
//    name      = "efs-storage-rasa"
//    host_path = "/model"
//    efs_volume_configuration =[{
//      file_system_id         = aws_efs_file_system.rasa.id
//      authorization_config = [{
//        access_point_id    = aws_efs_access_point.rasa_access_point.id
//        iam                = "ENABLED"
//      }]
//    }]
//  }]

//  dynamic "volume" {
//    for_each = var.volumes
//    content {
//      name = volume.key
//      host_path = volume.value.host_path
//
//      dynamic "efs_volume_configuration" {
//        for_each = volume.value.efs_volume_configuration
//        content {
//          file_system_id = efs_volume_configuration.value.file_system_id
//
//          dynamic "authorization_config" {
//            for_each = efs_volume_configuration.value.authorization_config
//            content {
//              access_point_id = authorization_config.value.access_point_id
//              iam = authorization_config.value.iam
//            }
//          }
//        }
//      }
//    }
//  }
