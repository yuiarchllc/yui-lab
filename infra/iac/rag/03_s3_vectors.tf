# S3 Vector Bucket and Index for RAG system
# This bucket stores vector embeddings and provides vector search capabilities

# S3 Vectors Bucket (using awscc provider for Cloud Control API support)
resource "awscc_s3vectors_vector_bucket" "vectors" {
  vector_bucket_name = local.vector_bucket_name
}

# S3 Vectors Index for efficient vector search
resource "aws_s3vectors_index" "rag_index" {
  depends_on = [awscc_s3vectors_vector_bucket.vectors]

  vector_bucket_name = awscc_s3vectors_vector_bucket.vectors.vector_bucket_name
  index_name         = local.vector_index_name

  # Vector configuration matching Titan Embed Text v2
  dimension       = local.vector_dimensions
  data_type       = local.vector_data_type
  distance_metric = local.distance_metric

  tags = local.common_tags
}
