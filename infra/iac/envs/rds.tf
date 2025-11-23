resource "aws_rds_cluster" "this" {
  cluster_identifier = "${local.general.service_name}-aurora"
  engine             = local.db.cluster.engine
  engine_version     = local.db.cluster.engine_version
  database_name      = local.db.cluster.database_name
  master_username    = local.db.cluster.master_username
  # master_password         = "ThisIsPlainTextPassword0987!"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.this.id
  backup_retention_period       = 7
  preferred_backup_window       = "07:00-09:00"
  skip_final_snapshot           = true
  db_subnet_group_name          = aws_db_subnet_group.this.name
  vpc_security_group_ids = [
    aws_security_group.ec2.id,
  ]
}

resource "aws_rds_cluster_instance" "writer" {
  identifier           = "${local.general.service_name}-writer"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = local.db.instance.instance_class
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.this.name
}

resource "aws_rds_cluster_instance" "reader" {
  identifier           = "${local.general.service_name}-reader"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = local.db.instance.instance_class
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.this.name
}

data "aws_caller_identity" "current" {}

resource "null_resource" "show_rds_password" {
  depends_on = [
    aws_rds_cluster.this
  ]

  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash

REGION="${local.general.region}"
ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
KMS_KEY_ID="${aws_kms_alias.this.target_key_id}"
CLUSTER_NAME="${aws_rds_cluster.this.cluster_identifier}"

SECRET_ARN=$(aws secretsmanager list-secrets \
    --region "$REGION" \
    --query "SecretList[?KmsKeyId=='arn:aws:kms:$REGION:$ACCOUNT_ID:key/$KMS_KEY_ID' && contains(Description, '$CLUSTER_NAME')].ARN" \
    --output text)

if [ -z "$SECRET_ARN" ]; then
  echo "Error: Secret not found for cluster $CLUSTER_NAME"
  exit 1
fi

DB_PASSWORD=$(aws secretsmanager get-secret-value \
    --region "$REGION" \
    --secret-id "$SECRET_ARN" \
    --query 'SecretString' \
    --output text | jq -r '.password')

echo ""
echo "===== RDS MASTER PASSWORD for $CLUSTER_NAME ====="
echo "$DB_PASSWORD"
echo "================================================="
echo ""
EOT
  }
}