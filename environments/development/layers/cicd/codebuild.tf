
# ==============================================================================
# DATA
# ==============================================================================

data "template_file" "buildspec" {
  template = file("./../../../../../koala-devops-hiring-webapp/buildspec.yml")
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

data "aws_iam_policy_document" "codebuild_s3_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::kdh-codebuild/*"
    ]
  }
}

resource "aws_iam_policy" "codebuild_cloudwatch_policy" {
  name        = "KDHCodebuildCloudwatchAccess"
  path        = "/"
  description = "Cloudwatch policy for codebuild"
  policy      = data.aws_iam_policy_document.codebuild_cloudwatch_policy_document.json
}

resource "aws_iam_policy" "codebuild_s3_policy" {
  name        = "KDHCodebuildS3Access"
  path        = "/"
  description = "S3 policy for codebuild"
  policy      = data.aws_iam_policy_document.codebuild_s3_policy_document.json
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

resource "aws_s3_bucket" "codebuild_bucket" {
  bucket        = "kdh-codebuild"
  force_destroy = true
  acl           = "private"

  versioning {
    enabled = true
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "CodeBuildRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
  managed_policy_arns = concat(var.codebuild_policies_arns, [
    aws_iam_policy.codebuild_cloudwatch_policy.arn,
    aws_iam_policy.codebuild_s3_policy.arn
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
    name                   = "${var.environment}-webapp-build.zip"
    override_artifact_name = true
    packaging              = "ZIP"
    type                   = "S3"
    location               = "kdh-codebuild"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
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

resource "aws_codebuild_source_credential" "webapp_build" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.cicd_github_token
}

resource "aws_codebuild_webhook" "webapp_build" {
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
