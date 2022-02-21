
# ==============================================================================
# PROVIDERS
# ==============================================================================

provider "aws" {
  region = var.region
}

# ==============================================================================
# TERRAFORM
# ==============================================================================

terraform {
  backend "s3" {
    bucket = "kdh-tfstates"
    key    = "iam/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# DATA
# ==============================================================================

# data "terraform_remote_state" "kdh_database" {
#   backend = "s3"
#   config = {
#     bucket = "kdh-tfstates"
#     key    = "database/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }

# ==============================================================================
# RESSOURCES
# ==============================================================================

# IAM users
# ------------------------------------------------------------------------------
locals {
  iam_users_with_multiples = concat(var.iam_developers, var.iam_dbas, var.iam_data_analysts)
  iam_users                = distinct(local.iam_users_with_multiples)
}

resource "aws_iam_user" "user" {
  count         = length(local.iam_users)
  name          = element(local.iam_users, count.index)
  force_destroy = true

  tags = merge(var.tags, { name = "iam-user-${element(local.iam_users, count.index)}" })
}

# IAM groups
# ------------------------------------------------------------------------------

resource "aws_iam_group" "developer" {
  name = "${var.environment}-developer"
}

resource "aws_iam_group" "dba" {
  name = "${var.environment}-dba"
}

resource "aws_iam_group" "data_analyst" {
  name = "${var.environment}-data_analyst"
}

# IAM group membership
# ------------------------------------------------------------------------------

resource "aws_iam_group_membership" "developer" {
  name  = "${var.environment}-developer-group-membership"
  users = var.iam_developers
  group = aws_iam_group.developer.name

  depends_on = [
    aws_iam_user.user
  ]
}

resource "aws_iam_group_membership" "dba" {
  name  = "${var.environment}-dba-group-membership"
  users = var.iam_dbas
  group = aws_iam_group.dba.name

  depends_on = [
    aws_iam_user.user
  ]
}

resource "aws_iam_group_membership" "data_analyst" {
  name  = "${var.environment}-data-analysts-group-membership"
  users = var.iam_data_analysts
  group = aws_iam_group.data_analyst.name

  depends_on = [
    aws_iam_user.user
  ]
}

# IAM policy documents
# ------------------------------------------------------------------------------

resource "aws_iam_group_policy" "webapp" {
  name  = "${var.environment}-webapp-policy"
  group = aws_iam_group.developer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy" "database" {
  name  = "${var.environment}-database-policy"
  group = aws_iam_group.dba.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:*",
        ]
        Effect   = "Allow"
        Resource = "*"
        # Resource = [
        #   data.terraform_remote_state.kdh_database.outputs.kdh_rds_arn
        # ]
      },
    ]
  })
}
