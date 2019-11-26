output "id" {
  value = "${aws_vpc.default.id}"
}

output "security_group_id" {
  value = "${aws_security_group.default.id}"
}
