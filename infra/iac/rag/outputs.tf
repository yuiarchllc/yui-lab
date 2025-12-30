# Output values will be populated as resources are created
# This file is intentionally empty initially and will be updated in subsequent tasks

# S3 Data Source Bucket
output "data_source_bucket_name" {
  description = "Name of the S3 bucket used for storing source documents"
  value       = aws_s3_bucket.data_source.id
}

# S3 Vectors Index
output "vector_index_arn" {
  description = "ARN of the S3 Vectors Index used for vector search"
  value       = aws_s3vectors_index.rag_index.index_arn
}

output "vector_bucket_name" {
  description = "Name of the S3 Vectors bucket used for storing vector embeddings"
  value       = awscc_s3vectors_vector_bucket.vectors.vector_bucket_name
}

# Knowledge Base IAM Role
output "kb_role_arn" {
  description = "ARN of the IAM role used by Knowledge Base to access AWS services"
  value       = aws_iam_role.kb_role.arn
}

# Knowledge Base
output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base for application integration"
  value       = aws_bedrockagent_knowledge_base.rag_kb.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.rag_kb.arn
}

output "data_source_id" {
  description = "ID of the Knowledge Base Data Source for document ingestion"
  value       = aws_bedrockagent_data_source.rag_data_source.data_source_id
}

# Bedrock Agent IAM Role
output "agent_role_arn" {
  description = "ARN of the IAM role used by Bedrock Agent to access Knowledge Base and LLM models"
  value       = aws_iam_role.agent_role.arn
}
# Bedrock Agent
output "agent_id" {
  description = "ID of the Bedrock Agent for application integration"
  value       = aws_bedrockagent_agent.rag_agent.agent_id
}

output "agent_arn" {
  description = "ARN of the Bedrock Agent"
  value       = aws_bedrockagent_agent.rag_agent.agent_arn
}

output "agent_alias_id" {
  description = "ID of the Bedrock Agent Alias (prod) for invoking the agent"
  value       = aws_bedrockagent_agent_alias.prod.agent_alias_id
}

output "agent_name" {
  description = "Name of the Bedrock Agent"
  value       = aws_bedrockagent_agent.rag_agent.agent_name
}
