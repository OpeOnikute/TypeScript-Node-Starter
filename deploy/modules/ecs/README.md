# ECS (Elastic Container Service) Module
This is used to create an ECS cluster to serve our application using Docker containers. The cluster resides in the global VPC and can only be accessed by resources in the same VPC.

# Dependencies
- ECR Module - Used to get the docker image URL.
- ALB Resource - Provides load-balancing and external access to the cluster. This is defined in the same module, because of issues creating the `ecs_service` when split into different modules.

# Variables
- Application-specific variables (Described in the main pipeline).
- Other variables and their descriptions are in the `variables.tf` file.