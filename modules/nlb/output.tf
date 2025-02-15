output "arn" {
  description = "The ARN of the network_load_balancer"
  value       = aws_lb.nlb.arn
}