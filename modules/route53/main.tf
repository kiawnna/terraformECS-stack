resource "aws_route53_record" "record" {
  zone_id = var.hosted_zone_id
  name    = var.subdomain
  type    = var.record_type
  alias {
    name                   = var.lb_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.ALB.id
    evaluate_target_health = false
  }
}
data "aws_elb_hosted_zone_id" "ALB" {}
