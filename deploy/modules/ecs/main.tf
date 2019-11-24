/* the task definition for the web service */

module "ecr" {
  source = "../ecr"

  ecr_repo_name = "ecr-example"
}

data "template_file" "web" {
  template = "${file("${path.module}/task-definitions/web.json")}"

  vars {
    image           = "${module.ecr.repository_url}"
    DATABASE_URL    = "${var.DATABASE_URL}"
    PORT            = "${var.PORT}"
    REDIS_HOST      = "${var.REDIS_HOST}"
    SESSION_SECRET  = "${var.SESSION_SECRET}"
    FACEBOOK_ID     = "${var.FACEBOOK_ID}"
    FACEBOOK_SECRET = "${var.FACEBOOK_SECRET}"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_task_definition" "web" {
  family                = "web"
  container_definitions = "${data.template_file.web.rendered}"

  #   network_mode          = "awsvpc"
  cpu    = "256"
  memory = "512"
}

resource "aws_ecs_service" "web" {
  name            = "${var.ecs_service_name}"
  task_definition = "${aws_ecs_task_definition.web.arn}"
  desired_count   = 1
  cluster         = "${aws_ecs_cluster.cluster.id}"

  #   iam_role   = "${var.iam_role_arn}"
  #   depends_on = ["null_resource.module_depends_on"]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}
