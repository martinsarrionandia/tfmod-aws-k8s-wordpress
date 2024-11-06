data "aws_prefix_list" "s3_prefix_list" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${local.s3-region}.s3"]
  }
}

data "aws_s3_bucket" "cdn_bucket" {
  bucket = var.cdn-bucket-name
}