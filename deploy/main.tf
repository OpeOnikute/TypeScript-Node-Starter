provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

# Defines one global VPC here, shared across all the modules that need it.
module "vpc" {
  source      = "./modules/networking/vpc"
  environment = "${var.environment}"
}

# Defines the subnets in the VPC, also global and across multiple availability zones to enable
# the use of the ALB.
module "subnet" {
  source = "./modules/networking/subnet"

  vpc_id      = "${module.vpc.id}"
  environment = "${var.environment}"
}

# s3 bucket to store the builds. 
resource "aws_s3_bucket" "default" {
  bucket = "codepipeline-bucket-${lower(var.organization_name)}"
  acl    = "private"
}

module "codebuild" {
  source = "./modules/code-build"

  ecs_cluster_name = "${var.environment}-cluster"

  aws_region = "${var.aws_region}"

  repository_url = "${module.ecs.ecr_repo_url}"

  repo_name = "${var.repo_name}"

  # Bulding the arn string because of a bug with Terraform v11, where the arn of 
  # the s3 bucket isn't found after creation.
  s3_bucket_arn = "arn:aws:s3:::codepipeline-bucket-${lower(var.organization_name)}"
}

# CodePipeline definitions
# TODO: Move this into a template file
resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
     {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# TODO: Move this into a template file
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::codepipeline-bucket-${lower(var.organization_name)}",
        "arn:aws:s3:::codepipeline-bucket-${lower(var.organization_name)}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

# TODO: Move this into a template file
resource "aws_iam_role_policy" "ecs_full_access" {
  name = "codepipeline_ecs_full_access"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "application-autoscaling:DeleteScalingPolicy",
            "application-autoscaling:DeregisterScalableTarget",
            "application-autoscaling:DescribeScalableTargets",
            "application-autoscaling:DescribeScalingActivities",
            "application-autoscaling:DescribeScalingPolicies",
            "application-autoscaling:PutScalingPolicy",
            "application-autoscaling:RegisterScalableTarget",
            "appmesh:ListMeshes",
            "appmesh:ListVirtualNodes",
            "appmesh:DescribeVirtualNode",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:Describe*",
            "cloudformation:CreateStack",
            "cloudformation:DeleteStack",
            "cloudformation:DescribeStack*",
            "cloudformation:UpdateStack",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:DeleteAlarms",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:PutMetricAlarm",
            "codedeploy:CreateApplication",
            "codedeploy:CreateDeployment",
            "codedeploy:CreateDeploymentGroup",
            "codedeploy:GetApplication",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentGroup",
            "codedeploy:ListApplications",
            "codedeploy:ListDeploymentGroups",
            "codedeploy:ListDeployments",
            "codedeploy:StopDeployment",
            "codedeploy:GetDeploymentTarget",
            "codedeploy:ListDeploymentTargets",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:GetApplicationRevision",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:BatchGetApplicationRevisions",
            "codedeploy:BatchGetDeploymentGroups",
            "codedeploy:BatchGetDeployments",
            "codedeploy:BatchGetApplications",
            "codedeploy:ListApplicationRevisions",
            "codedeploy:ListDeploymentConfigs",
            "codedeploy:ContinueDeployment",
            "sns:ListTopics",
            "lambda:ListFunctions",
            "ec2:AssociateRouteTable",
            "ec2:AttachInternetGateway",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CancelSpotFleetRequests",
            "ec2:CreateInternetGateway",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateRoute",
            "ec2:CreateRouteTable",
            "ec2:CreateSecurityGroup",
            "ec2:CreateSubnet",
            "ec2:CreateVpc",
            "ec2:DeleteLaunchTemplate",
            "ec2:DeleteSubnet",
            "ec2:DeleteVpc",
            "ec2:Describe*",
            "ec2:DetachInternetGateway",
            "ec2:DisassociateRouteTable",
            "ec2:ModifySubnetAttribute",
            "ec2:ModifyVpcAttribute",
            "ec2:RunInstances",
            "ec2:RequestSpotFleet",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteRule",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeTargetGroups",
            "ecs:*",
            "events:DescribeRule",
            "events:DeleteRule",
            "events:ListRuleNamesByTarget",
            "events:ListTargetsByRule",
            "events:PutRule",
            "events:PutTargets",
            "events:RemoveTargets",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfiles",
            "iam:ListRoles",
            "logs:CreateLogGroup",
            "logs:DescribeLogGroups",
            "logs:FilterLogEvents",
            "route53:GetHostedZone",
            "route53:ListHostedZonesByName",
            "route53:CreateHostedZone",
            "route53:DeleteHostedZone",
            "route53:GetHealthCheck",
            "servicediscovery:CreatePrivateDnsNamespace",
            "servicediscovery:CreateService",
            "servicediscovery:GetNamespace",
            "servicediscovery:GetOperation",
            "servicediscovery:GetService",
            "servicediscovery:ListNamespaces",
            "servicediscovery:ListServices",
            "servicediscovery:UpdateService",
            "servicediscovery:DeleteService"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
        ],
        "Resource": "arn:aws:ssm:*:*:parameter/aws/service/ecs*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:DeleteInternetGateway",
            "ec2:DeleteRoute",
            "ec2:DeleteRouteTable",
            "ec2:DeleteSecurityGroup"
        ],
        "Resource": [
            "*"
        ],
        "Condition": {
            "StringLike": {
                "ec2:ResourceTag/aws:cloudformation:stack-name": "EC2ContainerService-*"
            }
        }
    },
    {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
            "*"
        ],
        "Condition": {
            "StringLike": {
                "iam:PassedToService": "ecs-tasks.amazonaws.com"
            }
        }
    },
    {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
            "arn:aws:iam::*:role/ecsInstanceRole*"
        ],
        "Condition": {
            "StringLike": {
                "iam:PassedToService": [
                    "ec2.amazonaws.com",
                    "ec2.amazonaws.com.cn"
                ]
            }
        }
    },
    {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
            "arn:aws:iam::*:role/ecsAutoscaleRole*"
        ],
        "Condition": {
            "StringLike": {
                "iam:PassedToService": [
                    "application-autoscaling.amazonaws.com",
                    "application-autoscaling.amazonaws.com.cn"
                ]
            }
        }
    },
    {
        "Effect": "Allow",
        "Action": "iam:CreateServiceLinkedRole",
        "Resource": "*",
        "Condition": {
            "StringLike": {
                "iam:AWSServiceName": [
                    "ecs.amazonaws.com",
                    "spot.amazonaws.com",
                    "spotfleet.amazonaws.com",
                    "ecs.application-autoscaling.amazonaws.com",
                    "autoscaling.amazonaws.com"
                ]
            }
        }
    }
]
}
EOF
}

// Commented-out temporarily because accessing the cluster from the ECS container 
// has proven very difficult, even with both of them placed in the same VPC and 
// with the same security group.
// The REDIS_HOST parameter being set is on from an external provider for now.
module "cache" {
  source = "./modules/elastic-cache"

  environment = "${var.environment}"
  cluster_id  = "${var.environment}-cluster"

  # Network-related variables
  security_group_id = "${module.vpc.security_group_id}"

  subnet_ids = "${module.subnet.private_ids}"
}

module "ecs" {
  source = "./modules/ecs"

  ecs_cluster_name = "${var.environment}-cluster"
  ecs_service_name = "${var.environment}-service"
  environment      = "${var.environment}"

  # Network-related variables
  subnets_ids       = "${module.subnet.private_ids}"
  public_subnet_ids = "${module.subnet.public_ids}"
  vpc_id            = "${module.vpc.id}"
  security_group_id = "${module.vpc.security_group_id}"

  # App environment variables
  DATABASE_URL = "${var.DATABASE_URL}"
  PORT         = "${var.PORT}"

  #   REDIS_HOST      = "${var.REDIS_HOST}"
  REDIS_HOST      = "redis://${module.cache.address}:6379"
  SESSION_SECRET  = "${var.SESSION_SECRET}"
  FACEBOOK_ID     = "${var.FACEBOOK_ID}"
  FACEBOOK_SECRET = "${var.FACEBOOK_SECRET}"

  module_depends_on = [
    "aws_iam_role_policy.codepipeline_policy",
  ]
}
