terraform {
  backend "s3" {
    bucket  = "yuiarch-sys-tf-state"
    key     = "yui-lab/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = local.general.region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}