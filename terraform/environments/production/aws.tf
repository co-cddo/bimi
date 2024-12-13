terraform {
  backend "s3" {
    bucket = "cddo-bimi-production-tfstate"
    key    = "terraform-co-cddo-bimi-production.tfstate"
    region = "eu-west-2"
  }
}

module "application" {
  source = "../../application"

  environment = "production"
}
