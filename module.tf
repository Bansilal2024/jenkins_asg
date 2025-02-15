provider "aws" {
}

terraform {
  backend "s3" {
    bucket                  = "eks-tcs-state-store"
    key                     = "terraform.tfstate"
    region                  = "ap-south-1"
    workspace_key_prefix    = tcs-eks-backend"
    profile                 = "default"
    shared_credentials_file = "~/.aws/credentials"
    #    role_arn     = "arn:aws:iam::"
  }
}
module "nlb" {
  source               = "./modules/nlb"
  vpc_id               = "vpc-090a9a18fa8d91cbb"
  v_subnet_ids         = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]
  name_suffix          = "NLB"
  v_tags               = {
    Name = "Odin_NLB"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_1" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-090a9a18fa8d91cbb"
  name_suffix       = "CDS_TG"
  port              = "traffic-port"
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD_CDS"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_2" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-090a9a18fa8d91cbb"
  name_suffix       = "TRAN_TG"
  port              = "traffic-port"
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD-TRAN"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_3" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-090a9a18fa8d91cbb"
  name_suffix       = "NONTRAN_TG"
  port              = "traffic-port"
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD-NONTRAN"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_4" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-090a9a18fa8d91cbb"
  name_suffix       = "LOGGER_TG"
  port              = "traffic-port"
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD-LOGGER"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_5" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-090a9a18fa8d91cbb"
  name_suffix       = "CACHE_TG"
  port              = "traffic-port"
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD-CACHE"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_target_group_6" {
  source            = "./modules/nlb_target_group"
  vpc_id            = "vpc-090a9a18fa8d91cbb"
  name_suffix       = "AUTH_TG"
  port              = "traffic-port"
  protocol          = "TCP"
  health_check_protocol = "TCP"
  v_tags                        = {
    Name = "ASLAWS-ASG-ODIN-PROD-AUTH"
    ENV  = "PROD"
    APP  = "ODIN"
   }
}

module "nlb_listener_1" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 9007
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_1.arn
}

module "nlb_listener_2" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 9005
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_2.arn
}

module "nlb_listener_3" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 9004
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_3.arn
}

module "nlb_listener_4" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 9003
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_4.arn
}

module "nlb_listener_5" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 9002
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_5.arn
}

module "nlb_listener_6" {
  source            = "./modules/nlb_listener"
  load_balancer_arn = module.nlb.arn
  port              = 9001
  protocol          = "TCP"
  target_group_arn  = module.nlb_target_group_6.arn
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
  vpc_id                        = "vpc-090a9a18fa8d91cbb"
  v_subnet_ids                  = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]
  v_ami                         = "ami-053b12d3152c0cc71"
  #name_suffix                   = "ASG-1"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "7jan25"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_1.arn] 
  v_user_data_file              = "./1.sh"
}

module "asg_2" {
  source                        = "./modules/autoscaling"
  vpc_id                        = "vpc-090a9a18fa8d91cbb"
  name_suffix                   = "TRAN"
  name_prefix                   = "TRAN"
  v_subnet_ids                  = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]
  v_ami                         = "ami-053b12d3152c0cc71"
  #name_suffix                   = "ASG-2"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "7jan25"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_2.arn]  
  v_user_data_file              = "./1.sh"
}

module "asg_3" {
  source                        = "./modules/autoscaling"
  vpc_id                        = "vpc-090a9a18fa8d91cbb"
  name_suffix                   = "NONTRAN"
  name_prefix                   = "NONTRAN" 
  v_subnet_ids                  = ["subnet-00db90154620ea95e", "subnet-0dae766cb72704ce7"]
  v_ami                         = "ami-053b12d3152c0cc71"
  #name_suffix                   = "ASG-3"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "7jan25"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_3.arn]  
  v_user_data_file              = "./1.sh"
  
}

module "asg_4" {
  source                        = "./modules/autoscaling"
  vpc_id                        = "vpc-090a9a18fa8d91cbb"
  name_suffix                   = "LOGGER"
  name_prefix                   = "LOGGER"
  v_subnet_ids                  = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]
  v_ami                         = "ami-053b12d3152c0cc71"
  #name_suffix                   = "ASG-4"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "7jan25"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_4.arn]  
  v_user_data_file              = "./1.sh"
}

module "asg_5" {
  source                        = "./modules/autoscaling"
  vpc_id                        = "vpc-090a9a18fa8d91cbb"
  name_suffix                   = "LOGGER"
  name_prefix                   = "LOGGER"
  v_subnet_ids                  = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]
  v_ami                         = "ami-053b12d3152c0cc71"
  #name_suffix                   = "ASG-5"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "7jan25"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_5.arn]  
  v_user_data_file              = "./1.sh"
}

module "asg_6" {
  source                        = "./modules/autoscaling"
  vpc_id                        = "vpc-090a9a18fa8d91cbb"
  name_suffix                   = "LOGGER"
  name_prefix                   = "LOGGER"
  v_subnet_ids                  = ["subnet-0525f9ae4c5fcbe4d", "subnet-06c6b347264d4fa98"]
  v_ami                         = "ami-053b12d3152c0cc71"
  #name_suffix                   = "ASG-6"
  ec2_instance_profile_name     = aws_iam_instance_profile.ec2_instance_profile.name
  v_key_name                    = "7jan25"
  v_desired_capacity            = 1
  v_min_capacity                = 1
  v_max_capacity                = 1
  target_group_arns             = [module.nlb_target_group_6.arn]  
  v_user_data_file              = "./1.sh"
}
 