resource "aws_lb_target_group" "nlb_tg" {
  name     = "my-nlb-target-group-${var.name_suffix}"
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  health_check {
    interval            = var.health_check_interval
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
  tags  = var.v_tags
}