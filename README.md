# Insurgency game server

This is a fully automated insurgency dedicated server setup on AWS. It uses:

* AWS ECS Fargate
* AWS ECR
* AWS CodeBuild
* Docker
* Terraform

## Requirements (on your local machine)

* Linux, MacOS
* AWS cli
* Terraform
* jq

## Setup

1. Clone this repo
2. Install all dependencies (on Mac, use `$ brew install jq awscli terraform`)
3. Create an AWS profile called "personal" (or edit `.env` with your own)
4. Run `$ bin/bootstrap` and fill the variable as expected
5. Execute the additional steps asked
6. Push the repository to Github

## Running/stopping the server

> $ bin/server start

This command will start the server and output the IP address. It might take a
while (about 4 min).

> $ bin/server stop

Stops the server and you won't be charged on AWS.
