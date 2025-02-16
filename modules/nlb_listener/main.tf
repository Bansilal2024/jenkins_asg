resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}

output "listener_arn" {
  description = "The ARN of the listener"
  value       = aws_lb_listener.lb_listener.arn
}
