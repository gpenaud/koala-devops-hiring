
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

variable "network_tfstate_bucket_path" {
  type    = string
  default = "network"
}

variable "network_vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "network_public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.100.1.0/24",
    "10.100.2.0/24"
  ]
}
