
# ==============================================================================
# DATA
# ==============================================================================

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_s3_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.codebuild_bucket.arn}",
      "${aws_s3_bucket.codebuild_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "codepipeline_codedeploy_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "codedeploy:*"
    ]
    resources = [
      "*"
    ]
  }
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

resource "aws_iam_policy" "codepipeline_s3_policy" {
  name        = "KDHCodepipelineS3Access"
  path        = "/"
  description = "S3 policy for codepipeline"
  policy      = data.aws_iam_policy_document.codepipeline_s3_policy_document.json
}

resource "aws_iam_policy" "codepipeline_codedeploy_policy" {
  name        = "KDHCodepipelineCodedeployAccess"
  path        = "/"
  description = "Codedeploy policy for codepipeline"
  policy      = data.aws_iam_policy_document.codepipeline_codedeploy_policy_document.json
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "CodePipelineRole"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.codepipeline_s3_policy.arn,
    aws_iam_policy.codepipeline_codedeploy_policy.arn
  ]
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.environment}-webapp-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket    = "kdh-codebuild"
        S3ObjectKey = "development-webapp-build.zip"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName     = var.cicd_application_name
        DeploymentGroupName = var.environment
      }
    }
  }
}
