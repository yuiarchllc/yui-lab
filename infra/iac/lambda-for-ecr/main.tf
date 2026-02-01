terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-for-ecr-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 最初に以下を実施してECRリポジトリだけを先に作成しておく必要がある
# terraform apply -target=aws_ecr_repository.this
resource "aws_ecr_repository" "this" {
  name                 = "lambda-for-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lambda_function" "this" {
  function_name = "lambda-for-ecr"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"

  image_uri = "${aws_ecr_repository.this.repository_url}:latest"

  timeout     = 10
  memory_size = 128

  architectures = ["x86_64"]
}