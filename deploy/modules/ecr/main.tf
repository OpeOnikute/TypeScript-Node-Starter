resource "aws_ecr_repository" "repo" {
  name                 = "${var.ecr_repo_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = "${var.scan_on_push}"
  }
}
