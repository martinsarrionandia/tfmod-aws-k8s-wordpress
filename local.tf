locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    "${var.domain}",
  )
  s3-region = data.aws_s3_bucket.cdn_bucket.region
  s3-cdn-wordpresss-uploads-path = "${var.cdn-bucket-name}/wpcontent/uploads"
  c1 = "c${substr(parseint(sha256(var.release-name),16),0,3)}"
  c2 = "c${substr(parseint(sha256(var.release-chart),16),0,3)}"
}