output "arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.nlb_tg.arn
}