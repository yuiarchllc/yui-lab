locals {
  general = {
    service_name = "yui-lab"
    region       = "ap-northeast-1"
  }
  route53 = {
    domain_name     = "mitsumune.click"
    sub_domain_name = "lab"
    zone_id         = "Z05000742TPFCB5Y6EWEG"
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
  alb = {
    idle_timeout = 900
  }
  ec2 = {
    ami              = "ami-0d5f5a4eaac1481cb"
    instance_type    = "t3.nano"
    root_volume_size = "10"
    root_volume_type = "gp3"
    ssh_cidr_blocks = [
      "133.200.162.32/32",
    ]
  }
}