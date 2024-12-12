variable "domain" {
  type = string
}

variable "hostname" {
  type    = string
  default = null
}

variable "release-name" {
  type = string
}

variable "release-repo" {
  type    = string
  default = "oci://registry-1.docker.io/bitnamicharts/"
}

variable "release-chart" {
  type    = string
  default = "wordpress"
}

variable "cdn-bucket-name" {
  type = string
}

variable "amazon-ebs-class" {
  type = string
}

variable "cluster-issuer" {
  type = string
}

variable "public-ip" {
  type = string
}

variable "ebs-volname-wordpress-root" {
  type = string
}

variable "ebs-volname-wordpress-mariadb" {
  type = string
}

variable "ebs-volname-wordpress-uploads" {
  type = string
}

variable "wordpress-credentials-arn" {
  type = string
}

variable "cdn-s3-user-secret-arn" {
  type = string
}

variable "initial-setup" {
  type    = bool
  default = "false"
}

variable "wordpress-uploads-dir" {
  type    = string
  default = "wp-content/uploads"
}

variable "additional-middlewares" {
  type    = list(map)
  default = []
}
