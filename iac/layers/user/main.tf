
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
    key    = "user/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

resource "aws_iam_user" "user" {
  for_each      = toset(var.aws_users)
  name          = each.value
  force_destroy = true

  tags = merge(var.tags, { name = "${var.env}-iam-user" })
}
