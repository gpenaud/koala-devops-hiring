
output "user_arns" {
  value = values(aws_iam_user.user)[*].name
}

output "user_names" {
  value = values(aws_iam_user.user)[*].arn
}
