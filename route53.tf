data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "this" {
  count   = 0
  zone_id = data.aws_route53_zone.this.id
  name    = local.fqdn
  type    = "A"
  ttl     = "300"
  records = [var.public-ip]
}