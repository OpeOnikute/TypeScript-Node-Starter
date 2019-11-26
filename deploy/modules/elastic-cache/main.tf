resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.environment}-cache-subnet"
  subnet_ids = ["${var.subnet_ids}"]
}

resource "aws_elasticache_replication_group" "default" {
  replication_group_id          = "${var.cluster_id}"
  replication_group_description = "Redis cluster for basic example"

  subnet_group_name          = "${aws_elasticache_subnet_group.default.name}"
  automatic_failover_enabled = false

  security_group_ids = ["${var.security_group_id}"]
  node_type          = "${var.cluster_node_type}"

  number_cache_clusters = 1
  parameter_group_name  = "default.redis5.0"
  port                  = 6379
}
