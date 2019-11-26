variable "cluster_engine" {
  default = "redis"
}

variable "cluster_node_type" {
  default = "cache.t2.micro"
}

variable "cluster_id" {
  description = "ID to assign the new cluster."
}

variable "environment" {
  description = "Name of the environment. e.g. production."
}

variable "subnet_ids" {
  type        = "list"
  description = "List of subnets allowed to access this resource."
}

variable "security_group_id" {
  description = "ID of the associated security group."
}
