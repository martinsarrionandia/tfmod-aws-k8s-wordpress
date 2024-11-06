data "aws_secretsmanager_secret" "wordpress" {
  arn = var.wordpress-credentials-arn
}

data "aws_secretsmanager_secret_version" "wordpress_current" {
  secret_id = data.aws_secretsmanager_secret.wordpress.id
}

data "aws_secretsmanager_secret" "s3_access" {
  arn = var.cdn-s3-user-secret-arn
}

data "aws_secretsmanager_secret_version" "s3_access_current" {
  secret_id = data.aws_secretsmanager_secret.s3_access.id
}