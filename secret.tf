data "aws_secretsmanager_secret" "wordpress" {
  arn = var.wordpress_credentials_arn
}

data "aws_secretsmanager_secret_version" "wordpress_current" {
  secret_id = data.aws_secretsmanager_secret.wordpress.id
}

data "aws_secretsmanager_secret" "s3_access" {
  arn = var.cdn_s3_user_secret_arn
}

data "aws_secretsmanager_secret_version" "s3_access_current" {
  secret_id = data.aws_secretsmanager_secret.s3_access.id
}

resource "kubernetes_secret_v1" "sync_uploads_s3" {
  metadata {
    name      = "sync-uploads-s3"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  data = {
    MC_HOST_s3 = "https://${local.aws_access_key_id}:${local.aws_secret_access_key}@s3.${local.s3_region}.amazonaws.com:443"
  }

  type = "Opaque"
}