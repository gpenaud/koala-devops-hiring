
variable "env" {
  description = "the ressource environment"
  default     = "local"
}

variable "name" {
  default = "dev"
}

variable "message" {
  default = "hello world"
}

variable "subnet_id" {}

variable "tags" {
  description = "the tags to add to ressource"
  default = {
    owner   = "koala"
    project = "devops-hiring"
  }
}
