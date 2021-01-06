//resource "aws_rds_cluster_instance" "cluster_instances" {
//  count              = 1
//  identifier         = "aurora-cluster-demo-${count.index}"
//  cluster_identifier = aws_rds_cluster.default.id
//  instance_class     = "db.t3.micro"
//  engine             = aws_rds_cluster.default.engine
//  engine_version     = aws_rds_cluster.default.engine_version
////  skip_final_snapshot = true
//}
//
//resource "aws_rds_cluster" "default" {
//  cluster_identifier = substr("${var.app_name}-${var.region}-${var.environment}-rdscluster",0 ,32 )
//  availability_zones = ["${var.region}b","${var.region}a"]
//  database_name      = "mydb"
//  engine             = "aurora-mysql"
//  master_username    = "foo"
//  master_password    = "barbut8chars"
//  skip_final_snapshot  = true
//  vpc_security_group_ids = [var.vpc_security_group_ids]
//  db_subnet_group_name = aws_db_subnet_group.default.name
//}
//
//resource "aws_db_subnet_group" "default" {
//  name       = substr("${var.app_name}-${var.region}-${var.environment}-db_subnet_group",0 ,32 )
//  subnet_ids = [var.subnet_id_1,var.subnet_id_2]
//
//  tags = {
//    Name = "${var.app_name}-${var.region}-${var.environment}-db_subnet_group"
//  }
//}

