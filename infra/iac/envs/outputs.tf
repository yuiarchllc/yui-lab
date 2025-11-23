output "ssm_start_session_command" {
  description = "Start an SSM session to the EC2 instance"
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}