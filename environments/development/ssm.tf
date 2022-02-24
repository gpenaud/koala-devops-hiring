
# ==============================================================================
# RESSOURCES
# ==============================================================================

# Application parameters
# ------------------------------------------------------------------------------

resource "aws_ssm_parameter" "application_name" {
  name        = "/${var.environment}/application/name"
  description = "The application name"
  type        = "String"
  value       = var.webapp_name

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "application_port" {
  name        = "/${var.environment}/application/port"
  description = "The application port"
  type        = "String"
  value       = var.webapp_port

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "application_domain" {
  name        = "/${var.environment}/application/domain"
  description = "The application domain"
  type        = "String"
  value       = aws_elb.webapp_elb.dns_name

  tags = {
    environment = var.environment
  }
}
