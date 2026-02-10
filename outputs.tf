output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "domain_url" {
  value = "https://koushikbijili.site"
}
