locals {
  target_groups = [
    "green",
    "blue",
  ]

  # httpsになったら、443,8443に変更
  https_ports = [
    "80",
    "8080",
  ]
}

variable "prefix" {
  type = string
}

variable "container_cpu" {
  type    = number
  default = 256
}

variable "container_memory" {
  type    = number
  default = 512
}

variable "container_port" {
  type    = number
  default = 80
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "cloudfront_domain_name" {
  type = string
}

variable "cloudfront_hosted_zone_id" {
  type = string
}
