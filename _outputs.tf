
output "elb_dns_name" {
  value = aws_elb.webapp_elb.dns_name
}

output "asg_id" {
  value = aws_autoscaling_group.webapp.id
}

output "elb_name" {
  value = aws_elb.webapp_elb.name
}
