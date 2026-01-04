# AWS Identity Center (内部ディレクトリ)

このディレクトリには、AWS Identity Centerの内部ディレクトリでユーザーを管理するTerraform設定が含まれています。

## 前提条件

### 手動で事前に作成が必要なもの

1. **AWS Identity Centerの有効化**
   - オーガナイゼーションのマネジメントアカウント（ルートアカウント）で実施
   - AWS Management Console → IAM Identity Center → Enable
   - インスタンスID: `ssoins-77585c593ebb9b56`
   - Identity Store ID: `d-9567ab2313`

2. **AWSプロファイルの設定**
   - プロファイル名: `yui-root`
   - マネジメントアカウント（156056043212）の認証情報を設定

## 構成

- **認証方式**: AWS Access Portalでのログイン
- **ユーザー管理**: Terraformで一元管理（`main.tf` の `locals.users` で定義）
- **外部IdP**: 使用しない（Identity Center内部ディレクトリ）
- **Permission Set**: AdministratorAccess（セッション時間: 12時間）

## 管理対象

### ユーザー
- `mitsumune` (keisuke@yuiarch.com)

### アカウント割り当て
- アカウント: `467737513669` (kiro)
- ユーザー: `mitsumune`
- 権限: AdministratorAccess

## 使用方法

### ユーザーの追加

`main.tf` の `locals.users` を編集：

```hcl
locals {
  users = {
    mitsumune = { ... }
    newuser = {
      display_name = "New User"
      given_name   = "New"
      family_name  = "User"
      email        = "newuser@example.com"
    }
  }
}
```

### アカウント割り当ての追加

`main.tf` の `locals.account_assignments` を編集：

```hcl
locals {
  account_assignments = {
    mitsumune_kiro = { ... }
    newuser_kiro = {
      user       = "newuser"
      account_id = "467737513669"
    }
  }
}
```

### Terraformの実行

```bash
cd infra/iac/identity-center

terraform init
terraform fmt
terraform plan
terraform apply
```

## ユーザーの初回ログイン設定

1. Terraformでユーザーを作成後、マネジメントコンソールから検証メールを送信
   - IAM Identity Center → Users → ユーザー選択 → "Send email verification"
2. ユーザーはメール内のリンクからパスワードを設定
3. Access Portal URL: https://d-9567ab2313.awsapps.com/start からログイン

## Access Portal

ユーザーは以下のURLからログインします：
- URL: https://d-9567ab2313.awsapps.com/start
- ログイン後、割り当てられたアカウントとロールが表示されます

## 注意事項

- Identity Centerはマネジメントアカウントでのみ管理可能
- ユーザー作成後の検証メール送信は手動で実施が必要
- パスワードはユーザー自身が初回ログイン時に設定
