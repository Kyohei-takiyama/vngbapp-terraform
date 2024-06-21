resource "aws_ecs_task_definition" "this" {
  family                   = "${var.prefix}-ecs-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-ecs-container"
      image     = "nginx:stable"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = 80
        }
      ]
      environment = [
        {
          name  = "ENV"
          value = "dev"
        }
      ]
    }
  ])

  lifecycle {
    ignore_changes = [container_definitions]
  }

  tags = {
    Name = "${var.prefix}-ecs-task-def"
  }
}
