resource "aws_route53_record" "this" {
  for_each = {
    for d in aws_acm_certificate.this.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  zone_id         = local.route53.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 172800
  records         = [each.value.record]
  allow_overwrite = true
}

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

resource "aws_acm_certificate" "this" {
  provider                  = aws.common
  domain_name               = local.route53.domain_name
  subject_alternative_names = ["*.${local.route53.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "this" {
  provider                = aws.common
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}