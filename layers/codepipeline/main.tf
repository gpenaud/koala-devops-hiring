
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
    key    = "codepipeline/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# DATA
# ==============================================================================

data "template_file" "buildspec" {
  template = file("./../../../koala-devops-hiring-webapp/buildspec.yml")
  vars = {
    environment = var.environment
  }
}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_cloudwatch_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:eu-west-1:272058263048:log-group:/aws/codebuild/*"
    ]
  }
}

resource "aws_iam_policy" "codebuild_cloudwatch_policy" {
  name        = "KDHCodebuildCloudwatchAccess"
  path        = "/"
  description = "Cloudwatch policy for codebuild"
  policy      = data.aws_iam_policy_document.codebuild_cloudwatch_policy_document.json
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

resource "aws_s3_bucket" "bucket" {
  bucket        = "kdh-codebuild"
  force_destroy = true
}

resource "aws_iam_role" "codebuild_role" {
  name               = "CodeBuildRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
  managed_policy_arns = concat(var.codebuild_policies_arns, [
    aws_iam_policy.codebuild_cloudwatch_policy.arn
  ])
}

resource "aws_codebuild_project" "webapp_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.environment}-webapp-build"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn

  artifacts {
    encryption_disabled    = false
    name                   = "${var.environment}-webapp-build"
    override_artifact_name = true
    packaging              = "ZIP"
    type                   = "S3"
    location               = "kdh-codebuild"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "ENABLED"
      location            = "kdh-codebuild/logs"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/gpenaud/koala-devops-hiring-webapp.git"
    git_clone_depth = 1
    buildspec       = data.template_file.buildspec.rendered
    git_submodules_config {
      fetch_submodules = true
    }
  }
}

resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "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"
}

resource "aws_codebuild_webhook" "example" {
  project_name = aws_codebuild_project.webapp_build.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "develop"
    }
  }
}
