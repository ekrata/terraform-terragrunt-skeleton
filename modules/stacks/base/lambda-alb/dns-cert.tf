
# # The domain to use for the cert ($environment.$app.$domain)
variable "domain" {
  type = string
  default = "ekrata.com"
}

locals {
  subdomain = "${var.environment}.${var.app}.${var.domain}"
}

resource "aws_route53_zone" "dev" {
  name = "${local.subdomain}"
  vpc {
    vpc_id = "${var.vpc}"
    vpc_region = "eu-west-2"
  }
}

resource "aws_route53_zone" "app" {
  name = "${var.domain}"
  vpc {
    vpc_id = "${var.vpc}"
    vpc_region = "eu-west-2"
  }

}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${local.subdomain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


# resource "aws_route53_record" "cert_validation" {
#   name    = "${local.dvo.resource_record_name}"
#   type    = "${local.dvo.resource_record_type}"
#   zone_id = "${aws_route53_zone.app.id}"
#   records = ["${local.dvo.resource_record_value}"]
#   ttl     = 60
# }



# resource "dns_ns_record_set" "www" {
#   zone = "ekrata.com."
#   name = "${var.domain}"
#   nameservers = aws_route53_zone["${var.environment}"].name_servers
#   ttl = 60
# }

resource "porkbun_dns_record" "app_ns" {
  name    = "hosted zone nameserver record"
  domain  = "${var.domain}"
  content = aws_route53_zone.app.name_servers
  type    = "NS"
}

resource "porkbun_dns_record" "dev_ns" {
  name    = "hosted zone nameserver record"
  domain  = "${local.subdomain}"
  content = aws_route53_zone.dev.name_servers
  type    = "NS"
}


resource "aws_route53_record" "acm_records" {
  # zone_id = "${aws_route53_zone.dev.zone_id}"
  # type    = "CNAME"
  # name    = "${local.subdomain}"
  # records = ["${aws_alb.main.dns_name}"]
  # ttl     = "30"

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records = [
    each.value.record
  ]
  ttl     = 60
  type    = each.value.type
  zone_id = aws_route53_zone.dev.zone_id
}

resource "aws_acm_certificate_validation" "acm_validation" {
  # certificate_arn         = "${aws_acm_certificate.cert.arn}"
  # validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_records : record.fqdn]
}

# The https endpoint that gets provisioned

output "validation" {
  value = [for record in aws_route53_record.acm_records : record.fqdn]
}

output "endpoint" {
  value = "https://${local.subdomain}"
}
