resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
}

resource "aws_security_group" "default" {
  vpc_id      = "${aws_vpc.default.id}"
  name        = "default-sg"
  description = "Allow egress from container"

  # Allow container make requests to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow requests from anywhere to port 80.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow requests to port 6379 from within the VPC
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags {
    Name        = "${var.environment}-default-sg"
    Environment = "${var.environment}"
  }
}
