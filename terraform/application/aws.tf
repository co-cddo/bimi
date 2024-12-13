variable "workspace_iam_roles" {
  default = {
    sandbox    = "arn:aws:iam::850995542422:role/terraform-deployment"
    production = "arn:aws:iam::897722671969:role/terraform-deployment"
  }
}

data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn     = var.workspace_iam_roles[var.environment]
    session_name = "terraform-deployment"
  }

  default_tags {
    tags = {
      "Service" : "BIMI for UK Gov",
      "Reference" : "https://github.com/co-cddo/bimi",
      "Environment" : var.environment
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  assume_role {
    role_arn     = var.workspace_iam_roles[var.environment]
    session_name = "terraform-deployment"
  }

  default_tags {
    tags = {
      "Service" : "BIMI for UK Gov",
      "Reference" : "https://github.com/co-cddo/bimi",
      "Environment" : var.environment
    }
  }
}
