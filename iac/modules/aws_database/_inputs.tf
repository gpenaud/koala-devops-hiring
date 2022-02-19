
variable "env" {
  description = "the ressource environment"
  default     = "local"
}

variable "username" {
  description = "RDS root user name"
  type        = string
}

variable "password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "users" {
  description = "IAM users allowed to check manage and monitor DBs"
  type        = list(string)
}

variable "tags" {
  description = "the tags to add to ressource"
  default = {
    owner   = "koala"
    project = "devops-hiring"
  }
}
