
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

variable "iam_developers" {
  description = "developer group members"
  type        = list(string)
}

variable "iam_dbas" {
  description = "dba group members"
  type        = list(string)
}

variable "iam_data_analysts" {
  description = "data_analyst group members"
  type        = list(string)
}
