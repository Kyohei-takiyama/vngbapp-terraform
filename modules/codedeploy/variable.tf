variable "prefix" {
  type = string
}

variable "ecs" {
  type = object({
    cluster_name = string
    service_name = string
  })
}

variable "lb_listener" {
  type = object({
    http_80   = string
    http_8080 = string
  })
}

variable "lb_target_group" {
  type = object({
    blue  = string
    green = string
  })
}
