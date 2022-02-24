
# aws ssm get-parameter
# aws --region=eu-west-1 ssm get-parameter --name "development/database_host" --with-decryption --output text --query Parameter.Value

# aws ssm get-parameter --name "name" --with-decryption --query 'Parameter.Value' --output text

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
    key    = "webapp/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# DATA
# ==============================================================================

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "kdh_network" {
  backend = "s3"
  config = {
    bucket = "kdh-tfstates"
    key    = "network/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# LOCALS
# ==============================================================================

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

# SSH keys
# ------------------------------------------------------------------------------

resource "aws_key_pair" "ssh_key" {
  key_name   = var.owner
  public_key = var.webapp_ssh_public_key

  tags = {
    owner   = var.owner
    project = var.project
  }
}

# IAM roles
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_get_ssm_parameters_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "webapp" {
  name               = "KDHEc2Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  ]

  inline_policy {
    name   = "KDHEc2GetSsmParametersPolicy"
    policy = data.aws_iam_policy_document.ec2_get_ssm_parameters_policy.json
  }
}

# resource "aws_iam_role_policy_attachment" "webapp_codedeploy" {
#   role       = aws_iam_role.webapp.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
# }

# IAM Instance profile
# ------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "webapp" {
  name = "codedeploy-webapp"
  role = aws_iam_role.webapp.name
}

# EC2
# ------------------------------------------------------------------------------

data "template_file" "webapp_init" {
  template = file("./../../scripts/user_data.sh.tpl")
  vars = {
    region      = var.region
    environment = var.environment
  }
}

resource "aws_security_group" "webapp" {
  name        = "${var.environment}-webapp-sg"
  description = "security group for my webapp"
  vpc_id      = data.terraform_remote_state.kdh_network.outputs.kdh_vpc_id

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      description = "allow ssh / http / https ports on ingress"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "allow all ports on egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    owner   = var.owner
    project = var.project
  }
}

resource "aws_launch_configuration" "webapp" {
  name_prefix = "${var.environment}-webapp-"

  image_id             = var.webapp_ami_id # Ubuntu 20.04 | x64
  instance_type        = var.webapp_instance_type
  key_name             = aws_key_pair.ssh_key.id
  iam_instance_profile = aws_iam_instance_profile.webapp.name

  security_groups = [
    aws_security_group.webapp.id
  ]

  associate_public_ip_address = true
  user_data                   = data.template_file.webapp_init.rendered


  lifecycle {
    create_before_destroy = true
  }
}

# ELB
# ------------------------------------------------------------------------------

resource "aws_security_group" "webapp_elb" {
  name        = "${var.environment}-webapp-elb-sg"
  description = "Allow HTTP(S) traffic to instances through Elastic Load Balancer"
  vpc_id      = data.terraform_remote_state.kdh_network.outputs.kdh_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    owner   = var.owner
    project = var.project
  }
}

resource "aws_elb" "webapp_elb" {
  name = "${var.environment}-webapp-elb"
  security_groups = [
    aws_security_group.webapp_elb.id
  ]
  subnets = data.terraform_remote_state.kdh_network.outputs.kdh_public_subnet_ids

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

  tags = {
    owner   = var.owner
    project = var.project
  }
}

resource "aws_autoscaling_group" "webapp" {
  name = "${aws_launch_configuration.webapp.name}-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 4

  health_check_type = "ELB"
  load_balancers = [
    aws_elb.webapp_elb.id
  ]

  launch_configuration = aws_launch_configuration.webapp.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"
  vpc_zone_identifier = data.terraform_remote_state.kdh_network.outputs.kdh_public_subnet_ids

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
}
