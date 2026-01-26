locals {
  fqdn = try(
    "${var.hostname}.${var.domain}",
    var.domain,
  )

  s3_region                      = data.aws_s3_bucket.cdn_bucket.region
  s3_cdn_wordpresss_uploads_path = "${var.cdn_bucket_name}/${var.wordpress_uploads_dir}"

  # Generate selinux-level from release name and chart. Example format is s0:123:456 
  c1            = "c${substr(parseint(sha256(var.release_name), 16), 0, 3)}"
  c2            = "c${substr(parseint(sha256(var.release_chart), 16), 0, 3)}"
  selinux-level = "s0:${local.c1},${local.c2}"

  middleware_cdn_rewrite_name         = "${var.release_name}-cdn-rewrite"
  middleware_cache_control_name       = "${var.release_name}-cache-control"
  middleware_wpadmin_ipallowlist_name = "${var.release_name}-wpadmin-ip-allowlist"

  aws_access_key_id     = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_access_key_id"]
  aws_secret_access_key = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_secret_access_key"]

  uploads_url = "https?://${local.fqdn}/${var.wordpress_uploads_dir}/"

  #Escaped twice for double the pleasure. \\\\ Equals one \ in middleware
  uploads_url_regex      = replace(local.uploads_url, ".", "\\\\.")
  uploads_url_json_regex = replace(local.uploads_url_regex, "/", "\\\\\\\\/")

  http_proxy_host = split(":", var.http_proxy.address)[0]
  http_proxy_port = split(":", var.http_proxy.address)[1]

  ip_allowlist = setunion(
    toset([var.public_ip]),
    toset(var.wpadmin_ip_allowlist),
    toset(["${chomp(data.http.my_current_ip.response_body)}/32"])
  )
}