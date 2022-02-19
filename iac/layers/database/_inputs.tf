
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

variable "database_users" {
  type = list(string)
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}
