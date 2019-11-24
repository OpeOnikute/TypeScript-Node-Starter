variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  default     = true
}

variable "ecr_repo_name" {
  default     = "example"
  description = "Name of the repository."
}
