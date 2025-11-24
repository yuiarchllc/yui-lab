output "ssm_start_session_command" {
  description = "Start an SSM session to the EC2 instance"
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}

output "api_url" {
  description = "The URL of the API endpoint"
  value       = "https://${local.route53.cdn_domain_name}.${local.route53.domain_name}/api/"
}

output "app_url" {
  description = "The URL of the App endpoint"
  value       = "https://${local.route53.cdn_domain_name}.${local.route53.domain_name}/app/"
}