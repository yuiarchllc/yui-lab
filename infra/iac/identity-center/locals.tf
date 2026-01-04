data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "main" {}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  instance_arn      = tolist(data.aws_ssoadmin_instances.main.arns)[0]

  users = {
    mitsumune = {
      display_name = "keisuke mitsumune"
      given_name   = "keisuke"
      family_name  = "mitsumune"
      email        = "keisuke@yuiarch.com"
    }
  }

  account_assignments = {
    mitsumune_kiro = {
      user       = "mitsumune"
      account_id = "467737513669"
    }
  }
}