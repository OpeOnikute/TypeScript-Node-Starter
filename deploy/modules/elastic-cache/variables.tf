variable "cluster_engine" {
  default = "redis"
}

variable "cluster_node_type" {
  default = "cache.t2.micro"
}

variable "cluster_id" {
  description = "Id to assign the new cluster"
}

variable "environment" {}
