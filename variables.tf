locals {
  aws_region        = "ap-northeast-1"
  env               = "dev"
  service           = "vngbapp"
  gh_reponame       = "vngbapp-v2"
  github-owner      = "Kyohei-takiyama"
  github-repo-front = "vngbapp-front"
  github-repo-back  = "vngbapp-backend"
  domain_name       = "vngb.link"
}

variable "prefix" {
  type    = string
  default = "vngb-v2"
}

variable "account_id" {
  type = string
}

variable "github-oidc-endpoint" {
  description = "The GitHub OIDC endpoint"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "zone_id" {
  type = string
}
