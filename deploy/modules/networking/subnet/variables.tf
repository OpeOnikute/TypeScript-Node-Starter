# These defaults split the network into four logical subnets -
# 2 private subnets and 2 public subnets.
variable "cidr_block_private" {
  default     = ["10.0.8.0/24", "10.0.16.0/24"]
  type        = "list"
  description = "CIDR block list for the private subnet."
}

variable "cidr_block_public" {
  type        = "list"
  default     = ["10.0.32.0/24", "10.0.48.0/24"]
  description = "CIDR block list for the public subnet."
}

variable "vpc_id" {
  description = "ID of the VPC."
}

variable "environment" {
  description = "Name of the environment. e.g. production."
}

variable "availability_zones" {
  type    = "list"
  default = ["us-east-1a", "us-east-1b"]
}
