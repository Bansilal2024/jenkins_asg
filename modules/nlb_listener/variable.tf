variable "load_balancer_arn" {
  description = "The ARN of the load balancer"
  type        = string
}

variable "port" {
  description = "The port the listener should listen on"
  type        = number
}

variable "protocol" {
  description = "The protocol for the listener"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group the listener should forward traffic to"
  type        = string
}