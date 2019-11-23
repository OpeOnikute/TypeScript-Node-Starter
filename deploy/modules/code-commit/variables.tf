variable "repo_name" {
  description = "The name of the CodeCommit repository (e.g. new-repo)."
  default     = "example"
}

variable "repo_default_branch" {
  description = "The name of the default repository branch (default: master)"
  default     = "master"
}
