resource "aws_route53_record" "cloudfront_alias" {
  zone_id = local.route53.zone_id
  name    = local.route53.sub_domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}