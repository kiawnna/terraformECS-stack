# This is where you call the vpc module.
module "vpc" {
  source               = "../modules/vpc"
  app_name             = var.app_name
  vpc_cidr_block       = "10.200.0.0/16"
  region               = var.region
  public_subnet1_cidr_block = "10.200.0.0/24"
  public_subnet2_cidr_block = "10.200.1.0/24"
}
module "ec2-security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = substr("${var.app_name}-${var.region}-${var.environment}-ec2securityGroup", 0,32 )
  sg_ingress_rules = [
    {
      description = "All traffic on port 22"
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = [module.load-balancer-security-group.security_group_id]
    }]
  egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]

}
module "ecs-service-security-group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = substr("${var.app_name}-${var.region}-${var.environment}-ecsSecurityGroup", 0,32 )
  sg_ingress_rules = [
    {
      description = "Allow traffic from public instances.security_group"
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = [module.load-balancer-security-group.security_group_id]
    }]
  egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]

}


module "load-balancer-security-group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = substr("${var.app_name}-${var.region}-${var.environment}-securityGroupLB", 0,32 )
  ingress_rules = [
    {
      description = "Allow traffic from public instances.security_group"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_block = "0.0.0.0/0"
    },
   {
      description = "Allow traffic from public instances.security_group"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_block = "0.0.0.0/0"
    }]
egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]


}