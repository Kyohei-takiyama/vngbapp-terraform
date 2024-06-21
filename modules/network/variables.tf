variable "vpc_cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "prefix" {
  type = string
}

locals {
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets     = [for cidr_block in cidrsubnets("10.10.0.0/16", 7, 7, 7, 7) : cidrsubnets(cidr_block, 1, 1)][0]
  private_subnets    = [for cidr_block in cidrsubnets("10.10.0.0/16", 7, 7, 7, 7) : cidrsubnets(cidr_block, 1, 1)][1]
}
