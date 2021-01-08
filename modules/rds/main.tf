resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.writer_count
  identifier         = "${var.app_name}-${var.environment}-${var.cluster_name}-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.instance_type
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  db_parameter_group_name = aws_db_parameter_group.group.name
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = substr("${var.app_name}-${var.region}-${var.environment}-rdscluster",0 ,32 )
  availability_zones = ["${var.region}b","${var.region}a"]
  database_name      = "mydb"
  engine             = "aurora-mysql"
  backup_retention_period = 5
  master_username    = "foo"
  master_password    = "barbut8chars"
  skip_final_snapshot  = true
  final_snapshot_identifier = "${var.app_name}-${var.environment}-${var.cluster_name}-final"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.group.name
  vpc_security_group_ids = [var.vpc_security_group_ids]
  db_subnet_group_name = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = substr("${var.app_name}-${var.region}-${var.environment}-db_subnet_group",0 ,32 )
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.app_name}-${var.region}-${var.environment}-db_subnet_group"
  }
}

resource "aws_rds_cluster_parameter_group" "group" {
  name   = "${var.app_name}-${var.environment}-${var.cluster_name}-pg"
  family = "aurora-mysql5.7"

   parameter {
    name = "max_connections"
    value = "2000"
  }
}

resource "aws_db_parameter_group" "group" {
  name   = "${var.app_name}-${var.environment}-${var.cluster_name}-pg"
  family = "aurora-mysql5.7"

  parameter {
    name = "max_connections"
    value = "2000"
  }
}

