# Complete pipeline for Continuous Delivery.
# Pulls from Github (Source), builds the image using CodeBuild, 
# and deploys to the ECS cluster.
resource "aws_codepipeline" "pipeline" {
  name = "${var.repo_name}-pipeline"

  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "codepipeline-bucket-opeonikute"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "${var.organization_name}"
        Repo       = "${var.repo_name}"
        Branch     = "${var.repo_default_branch}"
        OAuthToken = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.repo_name}-codebuild"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${var.environment}-cluster"
        ServiceName = "${var.environment}-service"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
