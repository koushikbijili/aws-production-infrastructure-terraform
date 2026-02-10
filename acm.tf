resource "aws_acm_certificate" "cert" {
#replace with your domain name
  domain_name       = "example.com"
  validation_method = "DNS"

  subject_alternative_names = ["www.emample.com"]

  lifecycle {
    create_before_destroy = true
  }
}

