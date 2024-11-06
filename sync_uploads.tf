resource "kubernetes_manifest" "sync_uploads" {
  manifest = yamldecode(templatefile("${path.module}/templates/deployment_sync_uploads.yaml",
    {
      release-name          = var.release-name
      namespace             = kubernetes_namespace.this.metadata.0.name
      uploads-claim         = "${kubernetes_persistent_volume_claim.wordpress_uploads.metadata.0.name}"
      s3-region             = local.s3-region
      s3-uploads-path       = local.s3-cdn-wordpresss-uploads-path
      aws_access_key_id     = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_access_key_id"]
      aws_secret_access_key = jsondecode(data.aws_secretsmanager_secret_version.s3_access_current.secret_string)["aws_secret_access_key"]
  }))
}