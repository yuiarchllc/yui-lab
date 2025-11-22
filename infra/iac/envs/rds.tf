resource "aws_rds_cluster" "this" {
  cluster_identifier      = "${local.general.service_name}-aurora"
  engine                  = local.db.cluster.engine
  engine_version          = local.db.cluster.engine_version
  database_name           = local.db.cluster.database_name
  master_username         = local.db.cluster.master_username
  master_password         = "ThisIsPlainTextPassword0987!"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids = [
    aws_security_group.ec2.id,
  ]
}

resource "aws_rds_cluster_instance" "writer" {
  identifier           = "${local.general.service_name}-writer"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = local.db.instance.instance_class
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.this.name
}

resource "aws_rds_cluster_instance" "reader" {
  identifier           = "${local.general.service_name}-reader"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = local.db.instance.instance_class
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.this.name
}