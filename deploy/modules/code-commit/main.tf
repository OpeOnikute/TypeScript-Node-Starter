resource "aws_codecommit_repository" "repo" {
  repository_name = "${var.repo_name}"
  description     = "${var.repo_name} repository."
  default_branch  = "${var.repo_default_branch}"
}
