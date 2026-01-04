terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "yui-tf-state"
    key     = "yui-lab/identity-center/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
    profile = "yui-root"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "yui-root"
}