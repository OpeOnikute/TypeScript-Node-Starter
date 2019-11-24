variable "aws_region" {
  description = "The AWS region to deploy into (default: us-east-1)."
  default     = "us-east-1"
}

variable "key_pair" {
  default = "personal-projects"
}

# Access keys are initialized as environment variables
variable "access_key" {}

variable "secret_key" {}

variable "organization_name" {
  description = "The organization name provisioning the template (e.g. acme)"
  default     = "acme"
}

variable "environment" {
  default = "production"
}

variable "char_delimiter" {
  default = "-"
}

# CodeCommit Module Variables
variable "repo_name" {
  description = "The name of the CodeCommit repository (e.g. new-repo)."
  default     = "new"
}

variable "repo_default_branch" {
  description = "The name of the default repository branch (default: master)"
  default     = "exercise"
}

# CodePipeline variables

variable "github_token" {}

# App-specific variables
variable "DATABASE_URL" {}

variable "PORT" {}
variable "REDIS_HOST" {}
variable "SESSION_SECRET" {}
variable "FACEBOOK_ID" {}
variable "FACEBOOK_SECRET" {}
