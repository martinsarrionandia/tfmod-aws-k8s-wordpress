resource "kubernetes_manifest" "wordpress_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_wordpress.yaml",
    {
      release_name         = var.release_name,
      namespace            = kubernetes_namespace_v1.this.metadata[0].name
      http_proxy_app       = var.http_proxy.app
      http_proxy_namespace = var.http_proxy.namespace
      http_proxy_port      = local.http_proxy_port
      public_ip            = var.public_ip
  }))
}

resource "kubernetes_manifest" "mariadb_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_mariadb.yaml",
    {
      release_name = var.release_name,
      namespace    = kubernetes_namespace_v1.this.metadata[0].name
  }))
}

resource "kubernetes_manifest" "sync_uploads_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_sync_uploads.yaml",
    {
      release_name   = var.release_name,
      namespace      = kubernetes_namespace_v1.this.metadata[0].name
      s3-prefix-list = data.aws_prefix_list.s3_prefix_list.cidr_blocks
  }))
}