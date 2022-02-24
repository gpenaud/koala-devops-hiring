
variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "owner" {
  type = string
}

variable "project" {
  type = string
}

variable "tags" {
  description = "the tags to add to ressource"
  default = {
    owner   = "koala"
    project = "devops-hiring"
  }
}

variable "codebuild_policies_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
  ]
}

variable "codedeploy_role" {
  type = list(string)
  default = [
    "AmazonEC2RoleforAWSCodeDeploy",
  ]
}

variable "cicd_application_name" {
  type = string
}

variable "cicd_github_token" {
  type = string
}
