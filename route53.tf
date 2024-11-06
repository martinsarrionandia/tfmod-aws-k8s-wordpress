data "aws_route53_zone" "domain" {
  name         = var.domain
  private_zone = false
}