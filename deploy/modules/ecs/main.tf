# Load balancer and ECS are in the same module to avoid issues creating.
# See - https://github.com/hashicorp/terraform/issues/18258
module "ecr" {
  source = "../ecr"

  ecr_repo_name = "ecr-example"
}

# Used to generate a random ID for naming resources.
resource "random_id" "target_group_sufix" {
  byte_length = 2
}

# TODO: Move to file
data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
    ]
  }
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs_service_role_policy"

  policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* role that the Amazon ECS container agent and the Docker daemon can assume */
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = "${file("${path.module}/policies/ecs-task-execution-role.json")}"
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "ecs_execution_role_policy"
  policy = "${file("${path.module}/policies/ecs-execution-role-policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}

# Load balancer
resource "aws_alb" "alb_default" {
  name            = "${var.environment}-alb-default"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${var.security_group_id}", "${aws_security_group.web_inbound_sg.id}"]

  tags {
    Name        = "${var.environment}-alb-default"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = "${aws_alb.alb_default.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.alb_target_group"]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name        = "${var.environment}-alb-target-group-${random_id.target_group_sufix.hex}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  # depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]

  lifecycle {
    create_before_destroy = true
  }
}

/* security group for ALB */
resource "aws_security_group" "web_inbound_sg" {
  name        = "${var.environment}-web-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-web-inbound-sg"
  }
}

# Cloudwatch Log Group to monitory logs from ECS containers
resource "aws_cloudwatch_log_group" "default" {
  name = "awslogs-test"

  tags = {
    Environment = "${var.environment}"
    Application = "${var.environment}-service"
  }
}

/*
* IAM service role for ECS
*/
data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_role.json}"
}

data "template_file" "web" {
  template = "${file("${path.module}/task-definitions/web.json")}"

  vars {
    image        = "${module.ecr.repository_url}"
    DATABASE_URL = "${var.DATABASE_URL}"
    PORT         = "${var.PORT}"

    REDIS_HOST      = "${var.REDIS_HOST}"
    SESSION_SECRET  = "${var.SESSION_SECRET}"
    FACEBOOK_ID     = "${var.FACEBOOK_ID}"
    FACEBOOK_SECRET = "${var.FACEBOOK_SECRET}"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.ecs_cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

/*
* ECS cluster, task and service definition
*/
resource "aws_ecs_task_definition" "web" {
  family                   = "web"
  container_definitions    = "${data.template_file.web.rendered}"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu          = "256"
  memory       = "512"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "aws_ecs_service" "web" {
  name            = "${var.ecs_service_name}"
  task_definition = "${aws_ecs_task_definition.web.arn}"
  desired_count   = 1
  cluster         = "${aws_ecs_cluster.cluster.id}"

  launch_type = "FARGATE"

  depends_on = ["aws_iam_role_policy.ecs_service_role_policy", "aws_alb.alb_default"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "web"
    container_port   = "80"
  }

  network_configuration {
    security_groups  = ["${var.security_group_id}"]
    subnets          = ["${var.subnets_ids}"]
    assign_public_ip = true
  }
}
