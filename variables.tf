variable "domain" {
  type = string
}

variable "hostname" {
  type    = string
  default = null
}

variable "release_name" {
  type = string
}

variable "release_repo" {
  type    = string
  default = "oci://registry-1.docker.io/bitnamicharts"
}

variable "release_chart" {
  type    = string
  default = "wordpress"
}

variable "release_version" {
  type    = string
  default = "latest"
}

variable "cdn_bucket_name" {
  type = string
}

variable "amazon_ebs_class" {
  type = string
}

variable "cluster_issuer" {
  type = string
}

variable "public_ip" {
  type = string
}

variable "ebs_volname_wordpress_root" {
  type = string
}

variable "ebs_volname_wordpress_mariadb" {
  type = string
}

variable "ebs_volname_wordpress_uploads" {
  type = string
}

variable "wordpress_credentials_arn" {
  type = string
}

variable "cdn_s3_user_secret_arn" {
  type = string
}

variable "initial_setup" {
  type    = bool
  default = "true"
}

variable "debug" {
  type    = bool
  default = "false"
}

variable "diagnostic" {
  type    = bool
  default = "false"
}

variable "wordpress_uploads_dir" {
  type    = string
  default = "wp-content/uploads"
}

variable "additional_middlewares_maps" {
  type    = list(map(string))
  default = []
}

variable "additional_middlewares" {
  type    = list(string)
  default = []
}

variable "wpadmin_ip_allowlist" {
  type    = list(string)
  default = []
}

variable "docker_legacy_repo" {
  description = "Use docker legacy repo"
  type        = bool
  default     = false
}

variable "http_proxy_app" {
  type = string
}

variable "http_proxy_namespace" {
  type = string
}

variable "http_proxy_address" {
  type = string
}

variable "php_max_upload" {
  type    = string
  default = "512M"
}