locals {
  route53 = {
    domain_name     = "mitsumune.click"
    sub_domain_name = "lab"
    zone_id         = "Z05121321C4XLWRFWE4U3"
  }
  s3 = {
    bucket_name         = "${local.route53.sub_domain_name}.${local.route53.domain_name}"
    statics_dir         = "../../../apps/statics"
    statics_path_prefix = ""
    content_types = {
      css  = "text/css"
      html = "text/html"
      js   = "application/javascript"
      json = "application/json"
      txt  = "text/plain"
      xml  = "application/xml"
      svg  = "image/svg+xml"
      png  = "image/png"
    }
  }
  cloudfront = {
    log_prefix = "access_log/"
  }
}