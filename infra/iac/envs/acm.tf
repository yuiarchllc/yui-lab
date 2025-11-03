module "acm_cloudfront" {
  source = "../modules/acm"
  providers = {
    aws = aws.virginia
  }
  domain_name = local.route53.domain_name
  zone_id     = local.route53.zone_id
}

module "acm_alb" {
  source      = "../modules/acm"
  domain_name = local.route53.domain_name
  zone_id     = local.route53.zone_id
}