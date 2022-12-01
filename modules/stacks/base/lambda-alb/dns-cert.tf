# The domain to use for the cert ($environment.$app.$domain)
variable "domain" {}



locals {
  subdomain = "${var.environment}.${var.app}.${var.domain}"
}

resource "aws_route53_zone" "app" {
  name = "${var.domain}"
}

resource "aws_kms_key" "app" {
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service",
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Action = "kms:CreateGrant",
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service to CreateGrant",
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}



# data "aws_route53_zone" "app" {
#   name = "${var.domain}"
# }

resource "aws_route53_record" "site_domain" {
  zone_id = aws_route53_zone.app.zone_id
  name    = aws_route53_zone.app.name
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_key_signing_key" "app" {
  name  = "${local.subdomain}"
  hosted_zone_id             = aws_route53_zone.app.id
  key_management_service_arn = aws_kms_key.app.arn
}

resource "aws_route53_hosted_zone_dnssec" "app" {
  depends_on = [
    aws_route53_key_signing_key.app
  ]
  hosted_zone_id = aws_route53_key_signing_key.app.hosted_zone_id
}


resource "aws_route53_record" "main" {
  allow_overwrite = true
  zone_id = "${aws_route53_zone.app.zone_id}"
  type    = "CNAME"
  name    = "${local.subdomain}"
  records = [local.subdomain]
  ttl     = 5
}

resource "aws_route53_record" "nameservers" {
  allow_overwrite = true
  name            = local.subdomain
  ttl             = 5
  type            = "NS"
  zone_id         = aws_route53_zone.app.zone_id

  records = aws_route53_zone.app.name_servers
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain}"
  subject_alternative_names = ["*.${var.domain}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  dvo = tolist(aws_acm_certificate.cert.domain_validation_options)[0]
}

  # for_each = {
  #   for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
  #     name   = dvo.resource_record_name
  #     record = dvo.resource_record_value
  #     type   = dvo.resource_record_type
  #   }
  # }

# resource "aws_route53_record" "cert_validation" {
#   name    = "${local.dvo.resource_record_name}"
#   type    = "${local.dvo.resource_record_type}"
#   zone_id = "${data.aws_route53_zone.app.id}"
#   records = ["${local.dvo.resource_record_value}"]
#   ttl     = 60
# }

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.app.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# The https endpoint that gets provisioned
output "endpoint" {
  value = "https://${local.subdomain}"
}