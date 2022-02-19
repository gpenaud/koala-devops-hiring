
variable "env" {
  description = "the ressource environment"
  default     = "local"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "tags" {
  description = "the tags to add to ressource"
  default = {
    owner   = "koala"
    project = "devops-hiring"
  }
}
