resource "aws_ecr_repository" "this" {
  name                 = local.ecr.repos.api
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = local.ecr.repos.api
  }
}