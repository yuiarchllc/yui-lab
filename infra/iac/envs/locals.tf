locals {
  s3 = {
    bucket_name  = "yui-lab-bucket"
    statics_dir = "../../../apps/statics"
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
}