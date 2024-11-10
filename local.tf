locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    "${var.domain}",
  )

  s3-region                      = data.aws_s3_bucket.cdn_bucket.region
  s3-cdn-wordpresss-uploads-path = "${var.cdn-bucket-name}/${wordpress-uploads-dir}"
  c1                             = "c${substr(parseint(sha256(var.release-name), 16), 0, 3)}"
  c2                             = "c${substr(parseint(sha256(var.release-chart), 16), 0, 3)}"
  selinux-level                  = "s0:${local.c1},${local.c2}"
  selinux-options = {
    level = local.selinux-level
  }

  wordpress-helm-values = <<EOF
containerSecurityContext:
  seLinuxOptions:
    level: ${local.selinux-level}

EOF
}