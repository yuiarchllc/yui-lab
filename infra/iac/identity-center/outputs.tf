output "identity_store_id" {
  value = local.identity_store_id
}

output "instance_arn" {
  value = local.instance_arn
}

output "users" {
  value = {
    for username, user in aws_identitystore_user.users : username => {
      user_id = user.user_id
      email   = user.emails[0].value
    }
  }
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "access_portal_url" {
  value = "https://${data.aws_ssoadmin_instances.main.identity_store_ids[0]}.awsapps.com/start"
}
