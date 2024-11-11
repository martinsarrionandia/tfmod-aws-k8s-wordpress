locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    "${var.domain}",
  )

  s3-region                      = data.aws_s3_bucket.cdn_bucket.region
  s3-cdn-wordpresss-uploads-path = "${var.cdn-bucket-name}/${var.wordpress-uploads-dir}"
  c1                             = "c${substr(parseint(sha256(var.release-name), 16), 0, 3)}"
  c2                             = "c${substr(parseint(sha256(var.release-chart), 16), 0, 3)}"
  selinux-level                  = "s0:${local.c1},${local.c2}"
  selinux-options = {
    level = local.selinux-level
  }

  middleware-cdn-rewrite-name = "${var.release-name}-cdn-rewrite"
  middleware-cdn-rewrite = "${kubernetes_namespace.this.metadata.0.name}-${local.middleware-cdn-rewrite-name}@kubernetescrd"
  middlewares = join(", ",  concat([local.middleware-cdn-rewrite], var.additional-middlewares))

  wordpress-helm-values = <<EOF
containerSecurityContext:
  seLinuxOptions:
    level: ${local.selinux-level}
resources:
  requests:
    cpu: 25m
mariadb:
  primary:
    resources:
      requests:
        cpu: 25m

EOF
}