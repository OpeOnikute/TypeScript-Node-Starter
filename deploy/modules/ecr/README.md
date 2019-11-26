# ECR (Elastic Container Registry) Module
This module is used to create an ECR to store built images. It is a vital part of the Continuous Delivery workflow.

Right now, it is only being used in the ECS module, but it can be re-used anywhere else across the infrastructure.

## Variables
-  `scan_on_push` - Indicates whether images are scanned after being pushed to the repository.
- `ecr_repo_name` - Name of the repository.
