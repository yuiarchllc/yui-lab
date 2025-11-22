resource "aws_kms_key" "this" {
  deletion_window_in_days = 7
  enable_key_rotation     = true
  is_enabled              = true
}

resource "aws_kms_alias" "this" {
  name          = local.kms.alias_name
  target_key_id = aws_kms_key.this.id
}