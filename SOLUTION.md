# SOLUTION

This branch contains the challenge solution.

## Dockerizing the app
- Users can easily spin up the app by running `docker-compose up -d` on their local machines.
- The local docker implementation contains three containers:
    1. Node - This is the main application. It is buiild using the Dockerfile as you can see in the compose file config. Runs on port 3000 on the host machine.
    2. Mongo - A local mongo instance on port 27017 on the host machine.
    3. Redis - Redis client on port 6379 on the host machine.

## Deployment using Terraform
The deployment automation solution and documentation, can be found in `deploy/README.md`. 

**PLEASE NOTE** - The URL for the solution is now http://production-alb-default-2054886402.us-east-1.elb.amazonaws.com. It changed because it shut down for the night to save cost. 