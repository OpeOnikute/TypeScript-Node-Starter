variable "DATABASE_URL" {}

variable "PORT" {}
variable "REDIS_HOST" {}
variable "SESSION_SECRET" {}
variable "FACEBOOK_ID" {}
variable "FACEBOOK_SECRET" {}

variable "repo_name" {}

variable "ecs_cluster_name" {}

variable "ecs_service_name" {}

variable "iam_role_arn" {}

variable "iam_role_policy_name" {}

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
