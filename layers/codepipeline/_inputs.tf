
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
