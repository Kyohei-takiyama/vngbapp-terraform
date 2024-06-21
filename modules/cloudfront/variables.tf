variable "prefix" {
  type = string
}

variable "s3" {
  type = object({
    bucket_regional_domain_name = string
    bucket_id                   = string
  })
}

variable "acm_certificate_arn" {
  type = string
}

variable "domain_name" {
  type = string
}
