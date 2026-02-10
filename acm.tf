resource "aws_acm_certificate" "cert" {
  domain_name       = "koushikbijili.site"
  validation_method = "DNS"

  subject_alternative_names = ["www.koushikbijili.site"]

  lifecycle {
    create_before_destroy = true
  }
}

