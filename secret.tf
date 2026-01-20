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