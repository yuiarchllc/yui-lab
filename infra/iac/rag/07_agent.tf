# Bedrock Agent
# This resource creates a Bedrock Agent that integrates with the Knowledge Base
# and manages conversation history automatically

resource "aws_bedrockagent_agent" "rag_agent" {
  agent_name              = local.agent_name
  agent_resource_role_arn = aws_iam_role.agent_role.arn
  foundation_model        = local.llm_model_id

  instruction = <<-EOT
    あなたは、ナレッジベースに保存されたドキュメントを参照して質問に回答するアシスタントです。

    以下のルールに従ってください：
    1. ナレッジベースから関連情報を検索して回答してください
    2. 情報が見つからない場合は、正直にその旨を伝えてください
    3. 会話の文脈を考慮して、自然な対話を心がけてください
    4. 回答には、参照したドキュメントの情報源を含めてください
  EOT

  # Ensure IAM role and policy are fully configured before creating Agent
  depends_on = [
    aws_iam_role_policy_attachment.agent_policy_attachment
  ]

  tags = local.common_tags
}
# Bedrock Agent Knowledge Base Association
# This resource integrates the Agent with the Knowledge Base to enable RAG functionality

resource "aws_bedrockagent_agent_knowledge_base_association" "kb_association" {
  agent_id             = aws_bedrockagent_agent.rag_agent.agent_id
  knowledge_base_id    = aws_bedrockagent_knowledge_base.rag_kb.id
  description          = "RAG system knowledge base integration"
  knowledge_base_state = "ENABLED"

  # Ensure Agent is created before associating Knowledge Base
  depends_on = [aws_bedrockagent_agent.rag_agent]
}
# Bedrock Agent Alias
# This resource creates a production alias for the Agent

resource "aws_bedrockagent_agent_alias" "prod" {
  agent_id         = aws_bedrockagent_agent.rag_agent.agent_id
  agent_alias_name = "prod"
  description      = "Production alias for RAG agent"

  # Ensure Knowledge Base association is complete before creating alias
  depends_on = [aws_bedrockagent_agent_knowledge_base_association.kb_association]
}
