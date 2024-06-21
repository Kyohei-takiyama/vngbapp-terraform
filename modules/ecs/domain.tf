# https://budougumi0617.github.io/2020/11/07/define_https_subdomain_by_terraform/
####################################################
# Route53 Host Zone
####################################################
data "aws_route53_zone" "host_domain" {
  name = var.domain_name
}

resource "aws_route53_zone" "app_subdomain" {
  name = "app.${var.domain_name}"
}

resource "aws_route53_zone" "api_subdomain" {
  name = "api.${var.domain_name}"
}

####################################################
# Create NS record
####################################################
resource "aws_route53_record" "ns_record_for_app_subdomain" {
  name    = aws_route53_zone.app_subdomain.name
  type    = "NS"
  zone_id = data.aws_route53_zone.host_domain.id
  records = [
    aws_route53_zone.app_subdomain.name_servers[0],
    aws_route53_zone.app_subdomain.name_servers[1],
    aws_route53_zone.app_subdomain.name_servers[2],
    aws_route53_zone.app_subdomain.name_servers[3],
  ]
  ttl = 172800
}

resource "aws_route53_record" "ns_record_for_api_subdomain" {
  name    = aws_route53_zone.api_subdomain.name
  type    = "NS"
  zone_id = data.aws_route53_zone.host_domain.id
  records = [
    aws_route53_zone.api_subdomain.name_servers[0],
    aws_route53_zone.api_subdomain.name_servers[1],
    aws_route53_zone.api_subdomain.name_servers[2],
    aws_route53_zone.api_subdomain.name_servers[3],
  ]
  ttl = 172800
}

####################################################
# Create ACM
####################################################
resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = [format("*.%s", data.aws_route53_zone.host_domain.name)]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.prefix}-acm"
  }
}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.value]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.host_domain.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}

####################################################
# Create A Record for routing ALB
####################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/alb_hosted_zone_id
# data "aws_elb_hosted_zone_id" "main" {}
resource "aws_route53_record" "api_subdomain_alb" {
  zone_id = aws_route53_zone.api_subdomain.zone_id
  name    = aws_route53_zone.api_subdomain.name
  type    = "A"

  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = true
  }
}

####################################################
# Create A Record for cloudfront
####################################################
resource "aws_route53_record" "app_domain_cloudfront" {
  zone_id = data.aws_route53_zone.host_domain.zone_id
  name    = data.aws_route53_zone.host_domain.name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}
