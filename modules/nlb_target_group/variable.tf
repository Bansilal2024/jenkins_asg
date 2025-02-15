variable "vpc_id" {
  description = "The VPC ID where the resources will be deployed"
  type        = string
}

variable "name_suffix" {
  description = "Suffix to differentiate the target groups"
  type        = string
}

variable "port" {
  description = "Port to listen on for the target group"
  type        = number
}

variable "protocol" {
  description = "Protocol to use for the target group"
  type        = string
  default     = "TCP"
}

variable "health_check_interval" {
  description = "The interval between health checks"
  type        = number
  default     = 30
}

variable "health_check_protocol" {
  description = "The protocol to use for health checks"
  type        = string
  default     = "TCP"
}

variable "health_check_timeout" {
  description = "The timeout for health checks"
  type        = number
  default     = 10
}

variable "health_check_healthy_threshold" {
  description = "The healthy threshold for health checks"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "The unhealthy threshold for health checks"
  type        = number
  default     = 4
}
variable "v_tags" {
   description= "tags to define the network load balancer"
   type= map
   default = {
    Name = "Odin_NLB"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}