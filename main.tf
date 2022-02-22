
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

data "terraform_remote_state" "kdh_network" {
  backend = "s3"
  config = {
    bucket = "kdh-tfstates"
    key    = "network/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# RESSOURCES
# ==============================================================================

# SSH keys
# ------------------------------------------------------------------------------

resource "aws_key_pair" "ssh_key" {
  key_name   = "gpenaud"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLLNYwcvkVf6Zol/gE03XtMKc31gaALFzXeMyZXWfT1MAqgmpPF/lZWMjpzvA5X2xwDknSOQIOw27N8wKXlp9bBY6N2Nw5EbVOzW8eWKU/lCq0FkoE36yiBR+8ISV6eqc0BAJtYrv8AiujbGRApzf7kBGCXrDcdY4GKxiy1gqLBnnRxk+q9ystZBaC14YNnhaIzt1YhcVKPnj/BV+RUkL5Mmf5nlcqNKuOKmh0TZwJdjITwF6aRugKdajr03ZXL0MbaHG3bM8/DRoCLFXr53jPCuvAydNcLsaTvs6NjaXfUJJnKZ4L3vBHsmLB9vDXfA/mw8GYlnSn5O1PrLkZ1wbZOzcnFGZAUju8poY96WIVcQzc08Ne3zSxYlh0wAepy/8lhoV7ubkn2EhiWmawa5DYNQS/GJymFlYT0dGzOL6uyljB5KeFJm4J3zXl7secELVmezII6N9iBuz1B/vjCRYByAoV9PbGw6yn7g2Lt6byCjUmQk9MCR1dhly0uFJ14tgp6UX2TLn5o9eCj7MfQBVvOSV0fyyb1ijigJGRO1NIF3Ddz2fPzygt3aU4K3XRwEKaT4T9rau0ltGu7/LEpiS/8NT88lGMK3FeSyB0fq/6p25B58FrRzQf2vFk8l+dp1DfXl2C0k83c3gNE2BLtcW0puLF6pvNIwlTMV35k9xTVw== gpenaud@personal"

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

resource "aws_iam_role" "webapp" {
  name               = "webapp-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "webapp_codedeploy" {
  role       = aws_iam_role.webapp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# IAM Instance profile
# ------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "webapp" {
  name = "codedeploy-webapp"
  role = aws_iam_role.webapp.name
}

# EC2
# ------------------------------------------------------------------------------

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

  image_id             = "ami-0bf84c42e04519c85" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type        = "t2.nano"
  key_name             = aws_key_pair.ssh_key.id
  iam_instance_profile = aws_iam_instance_profile.webapp.name

  security_groups = [
    aws_security_group.webapp.id
  ]

  associate_public_ip_address = true
  user_data                   = file("user_data.sh")

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
