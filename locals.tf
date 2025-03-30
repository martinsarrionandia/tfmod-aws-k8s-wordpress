locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    var.domain,
  )

  s3-region                       = data.aws_s3_bucket.cdn_bucket.region
  s3-cdn-wordpresss-uploads-path  = "${var.cdn-bucket-name}/${var.wordpress-uploads-dir}"
  c1                              = "c${substr(parseint(sha256(var.release-name), 16), 0, 3)}"
  c2                              = "c${substr(parseint(sha256(var.release-chart), 16), 0, 3)}"
  selinux-level                   = "s0:${local.c1},${local.c2}"
  middleware-schema-redirect-name = "${var.release-name}-schema-redirect"
  middleware-cdn-rewrite-name     = "${var.release-name}-cdn-rewrite"
  middleware-cdn-rewrite          = "${kubernetes_namespace.this.metadata[0].name}-${local.middleware-cdn-rewrite-name}@kubernetescrd"
  middlewares                     = join(", ", concat([local.middleware-cdn-rewrite], var.additional-middlewares))
  aws_access_key_id               = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_access_key_id"]
  aws_secret_access_key           = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_secret_access_key"]
}