locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    var.domain,
  )

  s3-region                      = data.aws_s3_bucket.cdn_bucket.region
  s3-cdn-wordpresss-uploads-path = "${var.cdn-bucket-name}/${var.wordpress-uploads-dir}"
  c1                             = "c${substr(parseint(sha256(var.release-name), 16), 0, 3)}"
  c2                             = "c${substr(parseint(sha256(var.release-chart), 16), 0, 3)}"
  selinux-level                  = "s0:${local.c1},${local.c2}"
  middleware-cdn-rewrite-name    = "${var.release-name}-cdn-rewrite"
  middleware-cdn-rewrite         = "${kubernetes_namespace.this.metadata[0].name}-${local.middleware-cdn-rewrite-name}@kubernetescrd"
  middleware-cache-control-name  = "${var.release-name}-cache-control"
  middleware-cache-control       = "${kubernetes_namespace.this.metadata[0].name}-${local.middleware-cache-control-name}@kubernetescrd"
  middlewares                    = join(", ", concat([local.middleware-cache-control], [local.middleware-cdn-rewrite], var.additional-middlewares))
  aws_access_key_id              = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_access_key_id"]
  aws_secret_access_key          = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_secret_access_key"]
  uploads_url                    = "https?://${local.fqdn}/${var.wordpress-uploads-dir}/"
  #Escaped twice for double the pleasure. \\\\ Equals one \ in middleware
  uploads_url_regex      = replace(local.uploads_url, ".", "\\\\.")
  uploads_url_json_regex = replace(local.uploads_url_regex, "/", "\\\\\\\\/")
}