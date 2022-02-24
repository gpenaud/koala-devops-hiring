
# ==============================================================================
# DATA
# ==============================================================================

data "terraform_remote_state" "kdh_webapp" {
  backend = "s3"
  config = {
    bucket = "kdh-tfstates"
    key    = "webapp/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

# IAM Roles and policies
# ------------------------------------------------------------------------------

resource "aws_iam_role" "codedeploy_service" {
  name               = "codedeploy-service-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# S3
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "codedeploy_bucket" {
  bucket        = "kdh-codedeploy"
  force_destroy = true
}

# SNS
# ------------------------------------------------------------------------------

resource "aws_sns_topic" "codedeploy_webapp_sns_topic" {
  name = "webapp_sns_topic"
}

# CodeDeploy
# ------------------------------------------------------------------------------

resource "aws_codedeploy_app" "codedeploy_webapp" {
  name             = var.cicd_application_name
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_config" "codedeploy_webapp_config" {
  deployment_config_name = "CodeDeployDefault2.EC2AllAtOnce"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }
}

resource "aws_codedeploy_deployment_group" "codedeploy_webapp_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_webapp.name
  deployment_group_name = var.environment
  service_role_arn      = aws_iam_role.codedeploy_service.arn

  trigger_configuration {
    trigger_events = [
      "DeploymentFailure",
      "DeploymentSuccess",
      "DeploymentFailure",
      "DeploymentStop",
      "InstanceStart",
      "InstanceSuccess",
      "InstanceFailure"
    ]

    trigger_name       = "event-trigger"
    trigger_target_arn = aws_sns_topic.codedeploy_webapp_sns_topic.arn
  }

  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }

  load_balancer_info {
    elb_info {
      name = data.terraform_remote_state.kdh_webapp.outputs.elb_name
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  autoscaling_groups = [
    data.terraform_remote_state.kdh_webapp.outputs.asg_id
  ]
}
