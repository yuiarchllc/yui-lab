resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${local.general.service_name}-cluster"
  description                = "${local.general.service_name}-cluster"
  node_type                  = "cache.t3.micro"
  engine_version             = "5.0.6"
  port                       = 6379
  parameter_group_name       = "default.redis5.0"
  automatic_failover_enabled = true
  num_node_groups            = 1
  replicas_per_node_group    = 2
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids = [
    aws_security_group.redis.id,
  ]
  tags = {
    Name = "${local.general.service_name}-cluster"
  }
}