resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
}

resource "aws_security_group" "default" {
  vpc_id      = "${aws_vpc.default.id}"
  name        = "default-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags {
    Name        = "${var.environment}-default-sg"
    Environment = "${var.environment}"
  }
}
