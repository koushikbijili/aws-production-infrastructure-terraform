terraform {
  backend "s3" {
    bucket         = "koushik-prod-terraform-state-2026"
    key            = "production-architecture/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
