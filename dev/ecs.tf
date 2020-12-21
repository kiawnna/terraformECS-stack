module "load_balancer" {
  source             = "../modules/load_balancer"
  security_groups    = [module.load-balancer-security-group.security_group_id]
  subnets            = [module.vpc.subnet_id1, module.vpc.subnet_id2]
  app_name           = var.app_name
  region             = var.region
  environment        = var.environment
  target_group_arn   = module.target_group.target_group_arn
}
module "target_group" {
  source            = "../modules/target_group"
  app_name          = var.app_name
  region            = var.region
  environment       = var.environment
  vpc               = module.vpc.vpc_id
  load_balancer_arn = module.load_balancer.load_balancer_arn
  port              = 80
}
module "autoscaling_group" {
  source            = "../modules/autoscaling_group"
  app_name          = var.app_name
  region            = var.region
  environment       = var.environment
  launch_config_id  = module.ecs_module.launch_config_id
  subnet_id         = module.vpc.subnet_id1
  target_group_arns = [module.target_group.target_group_arn]

}
module "ecs_module" {
  source                       = "../modules/ecs_module"
  auto_scaling_group_arn       = module.autoscaling_group.autoscaling_group_arn
  target_group_arn             = module.target_group.target_group_arn
  container_name               = "Aleidy"
  region                       = var.region
  environment                  = var.environment
  container_port               = 80
  image_id                     = "ami-0128839b21d19300e"
  instance_type                = "t2.micro"
  launch-config-security-group = module.ec2-security_group.security_group_id
  subnets                      = [module.vpc.subnet_id1]
  security_group               = module.ecs-service-security-group.security_group_id
}

module "route53" {
  source                      = "../modules/route53"
  hosted_zone_id              = "Z01146212F8P0X6ZMXFNW"
  lb_dns_name                 = module.load_balancer.lb_dns_name
  subdomain                   = "test2"
}

