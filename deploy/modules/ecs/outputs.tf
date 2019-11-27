output "ecr_repo_url" {
  value = "${module.ecr.repository_url}"
}

output "load_balancer_dns" {
  value = "${aws_alb.alb_default.dns_name}"
}
