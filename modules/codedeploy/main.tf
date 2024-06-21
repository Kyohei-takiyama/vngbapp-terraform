##################
# IAM
##################
module "codedeploy_service_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true
  role_name   = "${var.prefix}-codedeploy-service-role"
  trusted_role_services = [
    "codedeploy.amazonaws.com"
  ]

  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS",
  ]
}

##################
# Codedeploy
##################
resource "aws_codedeploy_app" "this" {
  name = "${var.prefix}-codedeploy-app"

  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name = aws_codedeploy_app.this.name

  deployment_group_name  = "${var.prefix}-codedeploy-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  service_role_arn = module.codedeploy_service_role.iam_role_arn

  # 失敗時に自動でロールバック
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    # 切り替えるタイミング。ここではGreen環境が100%のトラフィックが流れたら自動で切り替える
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    # 1分後に古いリソースを削除
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs.cluster_name
    service_name = var.ecs.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.lb_listener.http_80]
      }

      test_traffic_route {
        listener_arns = [var.lb_listener.http_8080]
      }

      target_group {
        name = var.lb_target_group.blue
      }

      target_group {
        name = var.lb_target_group.green
      }
    }
  }
}
