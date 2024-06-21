############
# Security Group for ECS Service
############
resource "aws_security_group" "ecs_service" {
  name        = "${var.prefix}-ecs-service"
  description = "Security Group for ECS Service"
  vpc_id      = var.vpc_id

  # ALBからのみECSの通信を許可(80番ポート)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-ecs-service"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.prefix}-ecs-cluster"
  }
}

resource "aws_ecs_service" "this" {
  name                = "${var.prefix}-ecs-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.this.arn
  desired_count       = 1 # タスクの数
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  propagate_tags      = "SERVICE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.this[0].arn
    container_name   = "${var.prefix}-ecs-container"
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [
    aws_alb_listener.this
  ]

  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }

  tags = {
    Name = "${var.prefix}-ecs-service"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 0
    base              = 0
  }
}
