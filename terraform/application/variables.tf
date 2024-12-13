locals {
  use_acm = true

  prod_domain    = "bimi.service.security.gov.uk"
  nonprod_domain = "bimi.nonprod-service.security.gov.uk"
  domain         = var.environment == "production" ? local.prod_domain : local.nonprod_domain
}

variable "environment" {
  type        = string
  description = "BIMI Environment"
  default     = ""
}
