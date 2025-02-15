variable "vpc_id" {
  description = "The VPC ID where the resources will be deployed"
  type        = string
  default =  "vpc-090a9a18fa8d91cbb"
}
variable "v_subnet_ids" {
  description = "The subnet IDs where the EC2 instances will be launched"
  type        = list(string)
  default     = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]  
}
variable "v_sg_ib" {
  description = "Security group inbound rules. Map of port to allowed IP ranges."
  type        = map(list(string))
  default = {
    80    = ["0.0.0.0/0"]  # Allow HTTP (port 80) access from anywhere
    9001  = ["10.0.0.0/24"]  # Allow custom port 9001 from the 10.0.0.0/24 subnet
  }
}
variable "name_suffix" {
  description = "Suffix to differentiate the resources (e.g., NLB, ASG)"
  type        = string
  default     = "NLB"
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