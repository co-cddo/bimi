terraform {
  backend "s3" {
    bucket = "cddo-bimi-sandbox-tfstate"
    key    = "terraform-co-cddo-bimi-sandbox.tfstate"
    region = "eu-west-2"
  }
}

module "application" {
  source = "../../application"

  environment = "sandbox"
}
