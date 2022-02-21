
# ==============================================================================
# PROVIDERS
# ==============================================================================

provider "aws" {
  region = var.region
}

# provider "aws" {
#   region                      = var.region
#   access_key                  = "fake"
#   secret_key                  = "fake"
#   skip_credentials_validation = true
#   skip_metadata_api_check     = true
#   skip_requesting_account_id  = true
#
#   endpoints {
#     cloudwatch     = "http://localhost:4566"
#     ec2            = "http://localhost:4566"
#     iam            = "http://localhost:4566"
#     rds            = "http://localhost:4566"
#     s3             = "http://s3.localhost.localstack.cloud:4566"
#     secretsmanager = "http://localhost:4566"
#     ses            = "http://localhost:4566"
#     sns            = "http://localhost:4566"
#     sqs            = "http://localhost:4566"
#     ssm            = "http://localhost:4566"
#     sts            = "http://localhost:4566"
#   }
# }

# ==============================================================================
# TERRAFORM
# ==============================================================================

terraform {
  backend "s3" {
    bucket = "kdh-tfstates"
    key    = "network/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

module "kdh_network" {
  source              = "../../modules/aws_network"
  environment         = var.environment
  vpc_cidr            = var.network_vpc_cidr
  public_subnet_cidrs = var.network_public_subnet_cidrs

  tags = {
    owner       = var.owner
    project     = var.project
    environment = var.environment
  }
}
