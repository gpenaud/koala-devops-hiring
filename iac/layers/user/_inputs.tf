
variable "env" {
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

variable "aws_users" {
  description = "aws iam users to create"
  default = [
    "guillaume.penaud@gmail.com"
  ]
}

variable "tags" {
  description = "the tags to add to ressource"
  default = {
    owner   = "koala"
    project = "devops-hiring"
  }
}
