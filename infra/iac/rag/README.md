# RAG Infrastructure with AWS Bedrock

## 概要

このTerraformモジュールは、AWS Bedrock Knowledge BaseとBedrock Agentを活用したRAG (Retrieval-Augmented Generation) システムのインフラストラクチャを構築します。

### システムの目的

- 多様な形式のドキュメント（テキスト、CSV、Office、PDF、スキャンPDF）を保存・管理
- ドキュメントの自動ベクトル化とセマンティック検索
- Bedrock Agentによる会話履歴を保持した自然な対話
- LLMを活用した質問応答システムの実現

### 構成コンポーネント

- **S3 Data Source Bucket**: ソースドキュメントの保存
- **S3 Vectors**: ベクトル埋め込みの保存と検索
- **Bedrock Knowledge Base**: ドキュメントのベクトル化と検索管理
- **Bedrock Agent**: 会話履歴管理とLLMによる回答生成
- **IAM Roles**: 最小権限の原則に基づくアクセス制御

## 前提条件

### 必須ツール

- **AWS CLI**: バージョン2.x以上
  ```bash
  aws --version
  ```

- **Terraform**: バージョン1.0以上
  ```bash
  terraform version
  ```

### AWS設定

1. **AWS認証情報の設定**
   ```bash
   aws configure
   ```

2. **Bedrockモデルへのアクセス有効化**
   
   以下のモデルへのアクセスを有効にする必要があります：
   
   - Amazon Titan Embed Text v2 (`amazon.titan-embed-text-v2:0`)
   - Anthropic Claude 3 Sonnet (`anthropic.claude-3-sonnet-20240229-v1:0`)
   
   有効化手順：
   1. AWSマネジメントコンソールでBedrockサービスを開く
   2. 左メニューから「Model access」を選択
   3. 「Manage model access」をクリック
   4. 上記モデルにチェックを入れて「Request model access」をクリック

3. **必要な権限**
   
   デプロイを実行するIAMユーザー/ロールには以下の権限が必要です：
   - S3バケットの作成・管理
   - IAMロール・ポリシーの作成・管理
   - Bedrock Knowledge Base・Agentの作成・管理
   - S3 Vectorsの作成・管理

## デプロイ手順

### 1. Terraformの初期化

```bash
cd infra/iac/rag
terraform init
```

このコマンドは、必要なプロバイダー（AWS、AWSCC）をダウンロードし、Terraformの作業ディレクトリを初期化します。

### 2. 変数の設定

`terraform.tfvars`ファイルを作成し、必要な変数を設定します：

```hcl
project_name = "your-project-name"
aws_region   = "us-east-1"
```

**変数の説明:**
- `project_name`: リソース名のプレフィックスとして使用（小文字、数字、ハイフンのみ）
- `aws_region`: リソースをデプロイするAWSリージョン（デフォルト: us-east-1）

### 3. デプロイ計画の確認

```bash
terraform plan
```

このコマンドで、作成されるリソースの一覧と変更内容を確認できます。エラーがないことを確認してください。

### 4. リソースのデプロイ

```bash
terraform apply
```

確認プロンプトで`yes`と入力すると、リソースの作成が開始されます。完了まで数分かかります。

### 5. 出力値の確認

デプロイ完了後、重要な情報が出力されます：

```bash
terraform output
```

## 使用方法

### 1. ドキュメントのアップロード

Data Source BucketにドキュメントをアップロードしてKnowledge Baseに登録します：

```bash
# バケット名を取得
BUCKET_NAME=$(terraform output -raw data_source_bucket_name)

# ドキュメントをアップロード
aws s3 cp your-document.pdf s3://$BUCKET_NAME/
aws s3 cp your-document.txt s3://$BUCKET_NAME/
aws s3 cp your-document.xlsx s3://$BUCKET_NAME/
```

**サポートされるファイル形式:**
- テキストファイル (.txt) - 任意の文字コード
- CSVファイル (.csv)
- Microsoft Excel (.xlsx, .xls)
- Microsoft Word (.docx, .doc)
- Microsoft PowerPoint (.pptx, .ppt)
- PDF (.pdf) - テキストPDFおよびスキャンPDF（OCR処理）

### 2. Knowledge Baseの同期

初回デプロイ後、またはドキュメントを大量にアップロードした後は、手動で同期を実行します：

```bash
# Knowledge BaseとData Source IDを取得
KB_ID=$(terraform output -raw knowledge_base_id)
DS_ID=$(terraform output -raw data_source_id)

# 同期ジョブを開始
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id $KB_ID \
  --data-source-id $DS_ID \
  --region $(terraform output -raw aws_region)

# 同期ステータスを確認
aws bedrock-agent list-ingestion-jobs \
  --knowledge-base-id $KB_ID \
  --data-source-id $DS_ID \
  --region $(terraform output -raw aws_region)
```

同期が完了すると、ドキュメントがベクトル化され検索可能になります。

### 3. Agentのテスト

#### マネジメントコンソールでのテスト（推奨）

1. AWSマネジメントコンソールでBedrockサービスを開く
2. 左メニューから「Agents」を選択
3. 作成されたAgent（`{project_name}-rag-agent`）をクリック
4. 「Test」ボタンをクリック
5. チャット画面で質問を入力して動作確認

**テストポイント:**
- Knowledge Baseから情報を取得して回答するか
- 会話履歴が保持され、文脈を理解した回答ができるか
- 引用元（Citations）が表示されるか

#### AWS CLIでのテスト

```bash
# Agent情報を取得
AGENT_ID=$(terraform output -raw agent_id)
AGENT_ALIAS_ID=$(terraform output -raw agent_alias_id)
SESSION_ID="test-session-$(date +%s)"

# Agentに質問を送信
aws bedrock-agent-runtime invoke-agent \
  --agent-id $AGENT_ID \
  --agent-alias-id $AGENT_ALIAS_ID \
  --session-id $SESSION_ID \
  --input-text "ドキュメントに関する質問" \
  --region $(terraform output -raw aws_region) \
  output.txt

# 回答を確認
cat output.txt
```

### 4. Knowledge Base検索のテスト

Knowledge Baseに直接クエリを実行して、ベクトル検索をテストできます：

```bash
KB_ID=$(terraform output -raw knowledge_base_id)

aws bedrock-agent-runtime retrieve \
  --knowledge-base-id $KB_ID \
  --retrieval-query text="検索したいキーワード" \
  --region $(terraform output -raw aws_region)
```

## 出力値

デプロイ後、以下の出力値が利用可能です：

| 出力名 | 説明 | 用途 |
|--------|------|------|
| `data_source_bucket_name` | Data Source Bucketの名前 | ドキュメントアップロード先 |
| `vector_bucket_name` | Vector Bucketの名前 | ベクトルデータの保存先（自動管理） |
| `vector_index_arn` | S3 Vectors IndexのARN | ベクトル検索インデックスの識別子 |
| `knowledge_base_id` | Knowledge BaseのID | アプリケーション統合、検索クエリ実行 |
| `knowledge_base_arn` | Knowledge BaseのARN | IAMポリシーでの参照 |
| `data_source_id` | Data SourceのID | 同期ジョブの実行 |
| `kb_role_arn` | Knowledge Base IAMロールのARN | 権限確認、他モジュールでの参照 |
| `agent_id` | Bedrock AgentのID | Agent呼び出し |
| `agent_arn` | Bedrock AgentのARN | IAMポリシーでの参照 |
| `agent_alias_id` | Agent AliasのID | Agent呼び出し（prod環境） |
| `agent_name` | Agentの名前 | 識別用 |
| `agent_role_arn` | Agent IAMロールのARN | 権限確認、他モジュールでの参照 |

出力値の確認方法：

```bash
# すべての出力値を表示
terraform output

# 特定の出力値を取得
terraform output data_source_bucket_name
terraform output -raw knowledge_base_id
```

## クリーンアップ

リソースが不要になった場合、以下のコマンドですべてのリソースを削除できます：

```bash
terraform destroy
```

確認プロンプトで`yes`と入力すると、削除が開始されます。

**注意事項:**
- このモジュールは試作環境向けに`force_destroy = true`を設定しているため、S3バケット内のデータも含めて削除されます
- 本番環境では、削除保護の設定を検討してください
- 削除前に重要なドキュメントをバックアップしてください

### 部分的なクリーンアップ

特定のリソースのみを削除したい場合：

```bash
# 特定のリソースを削除
terraform destroy -target=aws_bedrockagent_agent.rag_agent

# Data Source Bucketの内容のみを削除（バケットは残す）
aws s3 rm s3://$(terraform output -raw data_source_bucket_name)/ --recursive
```

## トラブルシューティング

### デプロイエラー

**エラー: "Model access not granted"**
- Bedrockモデルへのアクセスが有効化されていません
- AWSコンソールでModel accessを確認し、必要なモデルを有効化してください

**エラー: "Insufficient permissions"**
- IAMユーザー/ロールに必要な権限がありません
- 管理者に権限の付与を依頼してください

### 同期エラー

**同期ジョブが失敗する**
- CloudWatch Logsでエラーログを確認してください
- サポートされていないファイル形式や破損ファイルが原因の可能性があります

### Agent実行エラー

**Agentが応答しない**
- Knowledge Baseの同期が完了しているか確認してください
- IAMロールの権限が正しく設定されているか確認してください

## 参考リンク

- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [S3 Vectors Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors.html)

## ライセンス

このプロジェクトは試作環境向けのサンプル実装です。本番環境での使用前に、セキュリティとコンプライアンスの要件を確認してください。
