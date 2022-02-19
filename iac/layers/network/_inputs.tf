
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

variable "network_tfstate_bucket_path" {
  type = string
}

variable "network_vpc_cidr" {
  type = string
}

variable "network_public_subnet_cidrs" {
  type = list(string)
}
