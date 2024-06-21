terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-bucket-vngb-v2"
    key    = "vngbapp/v2.tfstate"
    region = "ap-northeast-1"
  }
}
