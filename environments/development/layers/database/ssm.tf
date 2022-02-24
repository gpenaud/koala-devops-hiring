
# ==============================================================================
# RESSOURCES
# ==============================================================================

resource "aws_ssm_parameter" "database_host" {
  name        = "/developpement/database/host"
  description = "The database host"
  type        = "String"
  value       = module.kdh_database.rds_hostname

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "database_port" {
  name        = "/developpement/database/port"
  description = "The database port"
  type        = "String"
  value       = module.kdh_database.rds_port

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "database_name" {
  name        = "/developpement/database/name"
  description = "The database name"
  type        = "String"
  value       = module.kdh_database.rds_db_name

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "database_user" {
  name        = "/developpement/database/user"
  description = "The database user"
  type        = "String"
  value       = module.kdh_database.rds_username

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "database_password" {
  name        = "/developpement/database/password"
  description = "The database password"
  type        = "String"
  value       = "password"

  tags = {
    environment = var.environment
  }
}
