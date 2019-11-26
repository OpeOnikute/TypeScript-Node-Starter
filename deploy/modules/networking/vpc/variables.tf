variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "environment" {
  description = "Name of the environment. e.g. production."
}
