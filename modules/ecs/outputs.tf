output "ecr-repository-name" {
  value = aws_ecr_repository.this.name
}

output "http_80_arn" {
  value = aws_alb_listener.this["0"].arn
}

output "http_8080_arn" {
  value = aws_alb_listener.this["1"].arn
}

output "http_blue_target_group_arn" {
  value = aws_alb_target_group.this["0"].name
}

output "http_green_target_group_arn" {
  value = aws_alb_target_group.this["1"].name
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "task_role_name" {
  value = aws_iam_role.ecs_task_role.name
}

output "execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "load_balancer_dns_name" {
  value = aws_alb.this.dns_name
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "service_name" {
  value = aws_ecs_service.this.name
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "domain_name" {
  value = aws_acm_certificate.this.domain_name
}
