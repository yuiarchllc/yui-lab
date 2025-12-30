locals {
  # Naming conventions
  data_source_bucket_name = "${var.project_name}-rag-data-source-${data.aws_caller_identity.current.account_id}"
  vector_bucket_name      = "${var.project_name}-rag-vectors"
  vector_index_name       = "${var.project_name}-rag-index"
  knowledge_base_name     = "${var.project_name}-rag-kb"
  data_source_name        = "${var.project_name}-rag-data-source"
  agent_name              = "${var.project_name}-rag-agent"
  kb_role_name            = "${var.project_name}-rag-kb-role"
  agent_role_name         = "${var.project_name}-rag-agent-role"

  # Model configurations
  embedding_model_id  = "amazon.titan-embed-text-v2:0"
  embedding_model_arn = "arn:aws:bedrock:${var.aws_region}::foundation-model/${local.embedding_model_id}"

  llm_model_id  = "anthropic.claude-3-sonnet-20240229-v1:0"
  llm_model_arn = "arn:aws:bedrock:${var.aws_region}::foundation-model/${local.llm_model_id}"

  # Vector configuration
  vector_dimensions = 1024
  vector_data_type  = "float32"
  distance_metric   = "euclidean"

  # Common tags
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "development"
  }
}
