# 実装タスクリスト

## 概要

このタスクリストは、RAGシステムのインフラストラクチャをTerraformで実装するための具体的な手順を定義します。各タスクは段階的に実装し、前のタスクで作成したリソースを次のタスクで活用します。

## 完了済みタスク

以下のタスクは既に実装済みです：

- ✅ プロジェクト構造とTerraform基本設定（main.tf, variables.tf, outputs.tf, locals.tf）
- ✅ S3 Data Source Bucketの実装（02_s3_data_source.tf）
- ✅ S3 Vectors IndexとVector Bucketの実装（03_s3_vectors.tf）
- ✅ Knowledge Base用IAMロールの実装（04_iam_kb.tf）
- ✅ 関連する出力値の定義

## 残りのタスク

- [ ] 1. Bedrock Knowledge Baseの実装
  - [x] 1.1 Knowledge Baseリソースの作成
    - `05_knowledge_base.tf`ファイルを作成
    - Knowledge Baseを定義（`aws_bedrockagent_knowledge_base`、名前は`local.knowledge_base_name`）
    - `role_arn`に`aws_iam_role.kb_role.arn`を設定
    - `knowledge_base_configuration`ブロックで`type = "VECTOR"`を設定
    - `vector_knowledge_base_configuration`ブロック内で`embedding_model_configuration`を定義し、`embedding_model_arn = local.embedding_model_arn`を指定
    - `storage_configuration`ブロックで`type = "S3_VECTORS"`を設定
    - `s3_vectors_configuration`ブロックで`vector_index_arn = aws_s3vectors_index.rag_index.index_arn`を参照
    - IAMロールとの依存関係を明示的に設定（`depends_on`で`aws_iam_role_policy_attachment.kb_policy_attachment`を指定）
    - common_tagsを適用
    - _要件: 5.1, 5.2, 5.3, 5.4_

  - [x] 1.2 Data Sourceの作成
    - 同じファイル内にData Sourceリソースを定義（`aws_bedrockagent_data_source`、名前は`local.data_source_name`）
    - `knowledge_base_id`に`aws_bedrockagent_knowledge_base.rag_kb.id`を参照
    - `data_source_configuration`ブロックで`type = "S3"`を設定
    - `s3_configuration`ブロックで`bucket_arn = aws_s3_bucket.data_source.arn`を設定
    - Knowledge Baseとの依存関係を明示的に設定（`depends_on = [aws_bedrockagent_knowledge_base.rag_kb]`）
    - _要件: 5.4_

  - [x] 1.3 outputs.tfにKnowledge Base情報を追加
    - `knowledge_base_id`出力を定義（`aws_bedrockagent_knowledge_base.rag_kb.id`）
    - `knowledge_base_arn`出力を定義（`aws_bedrockagent_knowledge_base.rag_kb.arn`）
    - `data_source_id`出力を定義（`aws_bedrockagent_data_source.rag_data_source.data_source_id`）
    - 説明文を含める
    - _要件: 7.3_

- [ ] 2. Bedrock Agent用IAMロールの実装
  - [x] 2.1 Agent用IAMロールと信頼ポリシーの作成
    - `06_iam_agent.tf`ファイルを作成
    - Agent用IAMロールを定義（`aws_iam_role`、名前は`local.agent_role_name`）
    - 信頼ポリシーでbedrock.amazonaws.comを許可
    - 同一アカウント内のAgentリソースのみに制限する条件を追加（`StringEquals`条件で`aws:SourceAccount`を使用、`aws:SourceArn`はワイルドカードで`arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:agent/*`を指定）
    - common_tagsを適用
    - _要件: 4.1, 4.2_

  - [x] 2.2 Agent用IAM権限ポリシーの作成
    - IAMポリシードキュメントを定義（`aws_iam_policy_document`）
    - Bedrock LLMモデル呼び出し権限を追加（`bedrock:InvokeModel`、リソースは`local.llm_model_arn`）
    - Knowledge Base操作権限を追加（`bedrock:Retrieve`, `bedrock:RetrieveAndGenerate`、リソースは`aws_bedrockagent_knowledge_base.rag_kb.arn`）
    - IAMポリシーリソースを作成（`aws_iam_policy`、名前は`${local.agent_role_name}-policy`）
    - ロールにポリシーをアタッチ（`aws_iam_role_policy_attachment`）
    - ワイルドカード権限を使用しない
    - _要件: 4.3, 4.4, 4.5_

  - [x] 2.3 outputs.tfにAgent IAMロール情報を追加
    - `agent_role_arn`出力を定義（`aws_iam_role.agent_role.arn`）
    - 説明文を含める
    - _要件: 7.5_

- [ ] 3. Bedrock Agentの実装
  - [x] 3.1 Agentリソースの作成
    - `07_agent.tf`ファイルを作成
    - Agentを定義（`aws_bedrockagent_agent`、名前は`local.agent_name`）
    - `agent_resource_role_arn`に`aws_iam_role.agent_role.arn`を設定
    - `foundation_model`に`local.llm_model_id`を指定
    - `instruction`にエージェントインストラクションを設定（日本語で、ナレッジベースを参照して回答するように指示）
    - IAMロールとの依存関係を明示的に設定（`depends_on = [aws_iam_role_policy_attachment.agent_policy_attachment]`）
    - common_tagsを適用
    - _要件: 6.1, 6.3_

  - [x] 3.2 AgentとKnowledge Baseの統合
    - 同じファイル内にKnowledge Base Associationリソースを定義（`aws_bedrockagent_agent_knowledge_base_association`）
    - `agent_id`に`aws_bedrockagent_agent.rag_agent.agent_id`を参照
    - `knowledge_base_id`に`aws_bedrockagent_knowledge_base.rag_kb.knowledge_base_id`を参照
    - `description`に統合の説明を記載（例: "RAG system knowledge base integration"）
    - `knowledge_base_state = "ENABLED"`を設定
    - Agentとの依存関係を明示的に設定（`depends_on = [aws_bedrockagent_agent.rag_agent]`）
    - _要件: 6.4_

  - [x] 3.3 Agent Aliasの作成
    - 同じファイル内にAgent Aliasリソースを定義（`aws_bedrockagent_agent_alias`、alias_name: "prod"）
    - `agent_id`に`aws_bedrockagent_agent.rag_agent.agent_id`を参照
    - `description`にエイリアスの説明を記載（例: "Production alias for RAG agent"）
    - Knowledge Base Associationとの依存関係を明示的に設定（`depends_on = [aws_bedrockagent_agent_knowledge_base_association.kb_association]`）
    - _要件: 6.2_

  - [x] 3.4 outputs.tfにAgent情報を追加
    - `agent_id`出力を定義（`aws_bedrockagent_agent.rag_agent.agent_id`）
    - `agent_arn`出力を定義（`aws_bedrockagent_agent.rag_agent.agent_arn`）
    - `agent_alias_id`出力を定義（`aws_bedrockagent_agent_alias.prod.agent_alias_id`）
    - `agent_name`出力を定義（`aws_bedrockagent_agent.rag_agent.agent_name`）
    - 説明文を含める
    - _要件: 7.1, 7.2_

- [ ] 4. Terraformドキュメントの作成
  - [x] 4.1 README.mdの作成
    - `infra/iac/rag/README.md`を作成
    - プロジェクト概要を記載（RAGシステムの目的と構成）
    - 前提条件を記載（AWS CLI、Terraform 1.0以上、Bedrockモデルアクセス）
    - デプロイ手順を記載（terraform init/plan/apply）
    - 使用方法を記載（ドキュメントアップロード、Knowledge Base同期、Agentテスト）
    - クリーンアップ手順を記載（terraform destroy）
    - 出力値の説明を含める
    - _要件: 1.1_

  - [x] 4.2 terraform.tfvars.exampleの作成
    - `infra/iac/rag/terraform.tfvars.example`を作成
    - 必要な変数の例を記載（project_name、aws_region）
    - コメントで各変数の説明を追加
    - _要件: 1.2_

- [ ]* 5. デプロイとテスト
  - [x] 5.1 Terraform検証
    - `terraform validate`を実行して構文エラーがないことを確認
    - `terraform plan`を実行して計画を確認
    - 作成されるリソースの数と種類を確認
    - _要件: 1.1_

  - [x] 5.2 リソースのデプロイ
    - `terraform.tfvars`ファイルを作成（terraform.tfvars.exampleを参考に）
    - `terraform apply`を実行
    - すべてのリソースが正常に作成されることを確認
    - 出力値（knowledge_base_id、agent_id、bucket名など）を確認
    - _要件: 1.3_

  - [x] 5.3 Knowledge Baseの初回同期
    - AWS CLIでData Sourceの同期ジョブを開始（`aws bedrock-agent start-ingestion-job`）
    - 同期ステータスを確認（`aws bedrock-agent get-ingestion-job`）
    - 同期が完了することを確認
    - OCR機能を有効化（BEDROCK_DATA_AUTOMATION パーシング戦略）
    - IAMロールに必要な権限を追加（bedrock:InvokeDataAutomationAsync、bedrock:GetDataAutomationStatus）
    - ローカルから会話できるchat.shスクリプトを作成（セッション管理機能付き）
    - _要件: 2.4_
    - _Note: 画像PDFのOCR処理は一部失敗するケースあり。別タスクで改善予定_

  - [ ]* 5.4 テストドキュメントのアップロード
    - 各ファイル形式のサンプルドキュメントを作成
    - S3 Data Source Bucketにアップロード（`aws s3 cp`）
    - テキストファイル、CSV、Excel、Word、PowerPoint、PDFを含む
    - アップロード後、Knowledge Baseが自動的に処理することを確認
    - _要件: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [ ]* 5.5 Knowledge Base検索テスト
    - AWS CLIでベクトル検索を実行（`aws bedrock-agent-runtime retrieve`）
    - クエリに対して関連ドキュメントが取得できることを確認
    - 検索結果のスコアと内容を確認
    - _要件: 5.5_

  - [ ]* 5.6 Agent会話テスト
    - AWSマネジメントコンソールでBedrock > Agentsを開く
    - 作成されたAgentを選択してTestボタンをクリック
    - チャット画面で質問を入力
    - 会話を続けて、会話履歴が保持されることを確認（前の質問を参照した回答ができるか）
    - Knowledge Baseから情報を取得して回答することを確認（引用元が表示されるか）
    - _要件: 6.2, 6.4_

## 注意事項

- 各タスクは順番に実装してください（依存関係があります）
- タスク完了後は必ず`terraform plan`で変更内容を確認してください
- エラーが発生した場合は、CloudWatch LogsやTerraformのエラーメッセージを確認してください
- 試作環境のため、`force_destroy = true`を設定していますが、本番環境では削除保護を検討してください
