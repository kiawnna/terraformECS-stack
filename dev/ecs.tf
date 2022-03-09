module "load_balancer" {
  source             = "../modules/load_balancer"
  security_groups    = [module.load-balancer-security-group.security_group_id]
  subnets            = [module.vpc.subnet_id1, module.vpc.subnet_id2, module.vpc.subnet_id3]
  app_name           = var.app_name
  region             = var.region
  environment        = var.environment
  target_group_arn   = module.target_group.target_group_arn
  domain = "grafana.kiastests.com"
}
module "target_group" {
  source            = "../modules/target_group"
  app_name          = var.app_name
  region            = var.region
  environment       = var.environment
  vpc               = module.vpc.vpc_id
  load_balancer_arn = module.load_balancer.load_balancer_arn
  port              = 8080
}
module "autoscaling_group" {
  source            = "../modules/autoscaling_group"
  app_name          = "kia"
  region            = var.region
  environment       = var.environment
  launch_config_id  = module.ecs_module.launch_config_id
  subnet_id         = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2, module.vpc.private_subnet_id3]
  target_group_arns = [module.target_group.target_group_arn]

}

module "autoscaling_group2" {
  source            = "../modules/autoscaling_group"
  app_name          = "matt"
  region            = var.region
  environment       = var.environment
  launch_config_id  = module.ecs_module.launch_config_id
  subnet_id         = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2, module.vpc.private_subnet_id3]
  target_group_arns = [module.target_group.target_group_arn]

}

resource "aws_efs_file_system" "rasa" {
  encrypted = true
}

resource "aws_efs_access_point" "rasa_access_point" {
  file_system_id = aws_efs_file_system.rasa.id
}

module "ecs_module" {
  source                       = "../modules/ecs_module"
  auto_scaling_group_arn       = module.autoscaling_group.autoscaling_group_arn
  app_name="kia"
  target_group_arn             = module.target_group.target_group_arn
  container_name               = "kia"
  container_image              = "266245855374.dkr.ecr.us-east-1.amazonaws.com/krcdportal-dev"
  region                       = var.region
  environment                  = var.environment
  container_port               = 8080
  image_id                     = "ami-0128839b21d19300e"
  instance_type                = "t2.micro"
  launch-config-security-group = module.ec2-security_group.security_group_id
  subnets                      = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2, module.vpc.private_subnet_id3]
  security_group               = module.ecs-service-security-group.security_group_id
//  attach_efs_volume = true
//  efs_access_point = aws_efs_access_point.rasa_access_point.id
//  file_system_id = aws_efs_file_system.rasa.id
  root_directory = "/hello"
  volume_name = "kias-test-volume"
//  attach_efs_volume = true
  volumes = [{
    name = "kias-test-volume"
    efs_volume_configuration = [{
      file_system_id = aws_efs_file_system.rasa.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config = [{
        access_point_id = aws_efs_access_point.rasa_access_point.id
        iam = "ENABLED"
      }]
    }]
  }]
//  volume =[{
//    volume_name = "jio"
//    host_path = "/model"
//    file_system_id = aws_efs_file_system.rasa.id
//    access_point_id = aws_efs_access_point.rasa_access_point.id
//    iam = "ENABLED"
//  }]
}

module "ecs_module_no_volume" {
  source                       = "../modules/ecs_module"
  app_name="matt"
  auto_scaling_group_arn       = module.autoscaling_group2.autoscaling_group_arn
  target_group_arn             = module.target_group.target_group_arn
  container_name               = "matt"
  container_image              = "266245855374.dkr.ecr.us-east-1.amazonaws.com/anything"
  region                       = var.region
  environment                  = var.environment
  container_port               = 8080
  image_id                     = "ami-0128839b21d19300e"
  instance_type                = "t2.micro"
  launch-config-security-group = module.ec2-security_group.security_group_id
  subnets                      = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2, module.vpc.private_subnet_id3]
  security_group               = module.ecs-service-security-group.security_group_id
  attach_efs_volume = false
}


//
//
//module "route53" {
//  source                      = "../modules/route53"
//  hosted_zone_id              = "Z041955210OBNSJWB0NET"
//  lb_dns_name                 = module.load_balancer.lb_dns_name
//  subdomain                   = "grafan
