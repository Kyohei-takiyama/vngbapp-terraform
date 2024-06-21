resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb"
  description = "Allow HTTP and HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-alb"
  }
}

resource "aws_alb" "this" {
  name                       = "${var.prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  idle_timeout               = 600

  tags = {
    Name = "${var.prefix}-alb"
  }
}

resource "aws_alb_target_group" "this" {
  for_each    = { for idx, target_group in local.target_groups : idx => target_group }
  name        = "${var.prefix}-alb-tg-${each.value}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }

  tags = {
    Name = "${var.prefix}-alb-tg-${each.value}"
  }
}


resource "aws_alb_listener" "this" {
  for_each          = { for idx, port in local.https_ports : idx => port }
  load_balancer_arn = aws_alb.this.id
  port              = tonumber(each.value)
  #   todo ssl証明書を設定する
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this[each.key].arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

  tags = {
    Name = "${var.prefix}-alb-listener-${each.value}"
  }
}
