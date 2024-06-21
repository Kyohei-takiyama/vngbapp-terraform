provider "aws" {
  region = local.aws_region

  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = "dev"
      service       = local.service
      gh_reponame   = local.gh_reponame
    }
  }
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}
