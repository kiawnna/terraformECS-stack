module "rds" {
  source = "../modules/rds"
  subnet_ids = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2,module.vpc.private_subnet_id3]
  vpc_security_group_ids = module.db-security_group.security_group_id
  cluster_name = "aleidys-cluster"
}

module "db-security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = substr("${var.app_name}-${var.region}-${var.environment}-db-securityGroup", 0,32 )
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