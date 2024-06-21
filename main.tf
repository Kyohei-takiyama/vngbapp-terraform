module "network" {
  source = "./modules/network"

  prefix = var.prefix
}

module "ecs" {
  source = "./modules/ecs"

  prefix                    = var.prefix
  private_subnets           = module.network.private_subnets
  vpc_id                    = module.network.vpc_id
  public_subnets            = module.network.public_subnets
  domain_name               = local.domain_name
  zone_id                   = var.zone_id
  cloudfront_domain_name    = module.cloudfront.domain_name
  cloudfront_hosted_zone_id = module.cloudfront.hosted_zone_id
}

module "codedeploy" {
  source = "./modules/codedeploy"

  prefix = var.prefix
  ecs = {
    cluster_name = module.ecs.cluster_name
    service_name = module.ecs.service_name
  }

  lb_listener = {
    http_80   = module.ecs.http_80_arn
    http_8080 = module.ecs.http_8080_arn
  }

  lb_target_group = {
    blue  = module.ecs.http_blue_target_group_arn
    green = module.ecs.http_green_target_group_arn
  }
}

module "s3" {
  source = "./modules/s3"

  prefix      = var.prefix
  oic_iam_arn = module.cloudfront.oic_iam_arn
}

module "cloudfront" {
  source = "./modules/cloudfront"

  prefix = var.prefix
  s3 = {
    bucket_regional_domain_name = module.s3.bucket_regional_domain_name
    bucket_id                   = module.s3.bucket_id
  }
  acm_certificate_arn = aws_acm_certificate.us_east_1.arn
  domain_name         = module.ecs.domain_name
}

##################
# ACM for CloudFront 北部リージョンの証明書を取得する(ACM自体は手動で作成してImportする)
# https://qiita.com/jibirian999/items/6abf056d741281141f29
##################
resource "aws_acm_certificate" "us_east_1" {
  provider          = aws.acm_provider
  domain_name       = module.ecs.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = false
  }
}

