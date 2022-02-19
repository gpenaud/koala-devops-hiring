
# ==============================================================================
# DATA
# ==============================================================================

data "terraform_remote_state" "kdh_network" {
  backend = "s3"
  config = {
    bucket = "kdh-tfstates"
    key    = "network/terraform.tfstate"
    region = "eu-west-1"
  }
}

# ==============================================================================
# RESOURCES
# ==============================================================================

resource "aws_db_subnet_group" "kdh" {
  name       = "kdh"
  subnet_ids = data.terraform_remote_state.kdh_network.outputs.kdh_public_subnet_ids
  tags       = merge(var.tags, { name = "${var.env}-db-subnet-group" })
}

# resource "aws_db_parameter_group" "kdh" {
#   name   = "kdh"
#   family = "mysql57"
#
#   parameter {
#     name  = "log_connections"
#     value = "1"
#   }
#
#   tags = merge(var.tags, { name = "${var.env}-db-parameter-group" })
# }

resource "aws_db_instance" "kdh" {
  identifier           = "kdh"
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7"
  username             = var.username
  password             = var.password
  db_subnet_group_name = aws_db_subnet_group.kdh.name
  # vpc_security_group_ids = [aws_security_group.rds.id]
  # parameter_group_name = aws_db_parameter_group.kdh.name
  # publicly_accessible = true
  skip_final_snapshot = true
  tags                = merge(var.tags, { name = "${var.env}-db-instance" })
}
