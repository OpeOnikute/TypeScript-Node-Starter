output "private_ids" {
  value = "${aws_subnet.private_subnet.*.id}"
}

output "public_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}
