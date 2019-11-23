provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

module "codecommit" {
  source = "./modules/code-commit"

  repo_name           = "${var.repo_name}"
  repo_default_branch = "${var.repo_default_branch}"
}
