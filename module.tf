provider "aws" {
}

terraform {
  backend "s3" {
    bucket                  = "bansi-b3"
    key                     = "terraform.tfstate"
    region                  = "ap-southeast-1"
    workspace_key_prefix    = "bansi-b3"
    profile                 = "default"
    shared_credentials_file = "~/.aws/credentials"
    #    role_arn     = "arn:aws:iam::"
  }
}
module "nlb" {
  source               = "./modules/nlb"
  vpc_id               = "vpc-0034d7cc8bed4c897"
  v_subnet_ids         = ["subnet-04f195c3bda8a9c2a", "subnet-0046262582d2f3d7a"]
  name_suffix          = "NLB"
  v_tags               = {
    Name = "Odin_NLB"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_1" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-0034d7cc8bed4c897"
  name_suffix       = "CDS-TG"
  port              = 80
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD_CDS"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}


module "nlb_listener_1" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 80
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_1.arn
}



resource "aws_iam_role" "ec2_role" {
  name               = "ec2-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_role_policy_attachment" "ec2_role_policy_2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}


module "asg_1" {
  source                        = "./modules/autoscaling"
  name_suffix                   = "CDS"
  name_prefix                   = "CDS"
  vpc_id                        = "vpc-0034d7cc8bed4c897"
  v_subnet_ids                  = ["subnet-0ce6bce1ba5b30896", "subnet-005d8ca5ece26114e"]
  v_ami                         = "ami-0672fd5b9210aa093"
  #name_suffix                   = "ASG-1"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "16feb"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_1.arn]
  v_user_data_file              = "./1.sh"
}
