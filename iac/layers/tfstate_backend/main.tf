
# ==============================================================================
# PROVIDERS
# ==============================================================================

provider "aws" {
  region = var.region
}

# provider "aws" {
#   region                      = "eu-west-1"
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
# RESSOURCES
# ==============================================================================

resource "aws_s3_bucket" "bucket" {
  bucket        = "kdh-tfstates"
  force_destroy = true
  acl           = "private"

  versioning {
    enabled = true
  }
}
