resource "kubernetes_manifest" "wordpress_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_wordpress.yaml",
    {
      release-name = var.release-name,
      namespace    = kubernetes_namespace.this.metadata[0].name
  }))
}

resource "kubernetes_manifest" "mariadb_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_mariadb.yaml",
    {
      release-name = var.release-name,
      namespace    = kubernetes_namespace.this.metadata[0].name
  }))
}

resource "kubernetes_manifest" "sync_uploads_network_policy" {
  count = var.initial-setup == true ? 0 : 1
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_sync_uploads.yaml",
    {
      release-name   = var.release-name,
      namespace      = kubernetes_namespace.this.metadata[0].name
      s3-prefix-list = data.aws_prefix_list.s3_prefix_list.cidr_blocks
  }))
}