locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    "${var.domain}",
  )
  s3-region = data.aws_s3_bucket.cdn_bucket.region
  s3-cdn-wordpresss-uploads-path = "${var.cdn-bucket-name}/wpcontent/uploads"
}