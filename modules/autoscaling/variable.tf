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
variable "v_ami" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-053b12d3152c0cc71"
}
variable "name_suffix" {
  description = "Suffix to differentiate the resources (e.g., NLB, ASG)"
  type        = string
  default     = "ASG"
}
variable "name_prefix" {
   description = "Suffix to differentiate the resources (e.g., NLB, ASG)"
   type        = string
   default     = "ASG"
}
variable "v_key_name" {
  description = "The SSH key name for EC2 instances"
  type        = string
}
variable "ec2_instance_profile_name" {}

variable "v_desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}
variable "v_min_capacity" {
    description = "The minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}
variable "v_max_capacity" {
  description = "The maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}
variable "target_group_arns" {
  type=list
}
variable "asg_tags" {
  default = [
    {
      key                 = "Name"
      value               = "ODIN-ASG"
      propagate_at_launch = true
    },
    {
      key                 = "ENV"
      value               = "UAT"
      propagate_at_launch = true
    },
    {
      key                 = "APP"
      value               = "ODIN"
      propagate_at_launch = true
    },
  ]
}
variable "v_tags" {
   description= "tags to define the launch template"
   type= map
   default = {
    Name = "Odin_NLB"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}
variable "v_user_data_file" {
  description = "Path to the user data file"
  type        = string
  default     = "./1.sh"
}
