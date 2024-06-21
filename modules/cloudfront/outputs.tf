output "oic_iam_arn" {
  value = aws_cloudfront_origin_access_identity.static-www.iam_arn
}

output "domain_name" {
  value = aws_cloudfront_distribution.static-www.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.static-www.hosted_zone_id
}
