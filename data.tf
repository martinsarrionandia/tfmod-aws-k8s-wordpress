data "aws_prefix_list" "s3_prefix_list" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.eu-west-2.s3"]
  }
}

data "aws_s3_bucket" "cdn_bucket" {
  bucket = var.cdn-bucket-name
}