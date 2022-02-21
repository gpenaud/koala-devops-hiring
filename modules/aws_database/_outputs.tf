
output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.kdh.arn
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.kdh.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.kdh.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.kdh.username
  sensitive   = true
}
