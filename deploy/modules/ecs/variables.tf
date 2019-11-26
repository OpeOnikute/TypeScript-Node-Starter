# Application Environment variables
variable "DATABASE_URL" {}

variable "PORT" {}
variable "REDIS_HOST" {}
variable "SESSION_SECRET" {}
variable "FACEBOOK_ID" {}
variable "FACEBOOK_SECRET" {}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
}

variable "ecs_service_name" {
  description = "Name of the ECS service."
}

variable "vpc_id" {
  description = "ID of the VPC the cluster should reside in."
}

variable "environment" {
  description = "Name of the environment. e.g. production."
}

variable "subnets_ids" {
  type        = "list"
  description = "List of network subnets allowed access to the cluster."
}

variable "security_group_id" {
  description = "ID of the associated security group."
}

variable "public_subnet_ids" {
  type        = "list"
  description = "List of public subnets needed for the ALB."
}

/*
    Minor hack from - https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305
    Add the following line to the resource in this module that depends on the completion of external module components:

    depends_on = ["null_resource.module_depends_on"]

    This will force Terraform to wait until the dependant external resources are created before proceeding with the creation of the
    resource that contains the line above.

    This is a hack until Terraform officially support module depends_on.
*/
variable "module_depends_on" {
  default = [""]
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}
