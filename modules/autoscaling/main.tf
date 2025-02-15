resource "aws_security_group" "asg_sg" {
    name = " SG-ODIN-PROD-${var.name_suffix}"
    description = "Allow TLS inbound traffic"
    vpc_id      = var.vpc_id

    dynamic "ingress" {
      for_each = var.v_sg_ib
      content {
        cidr_blocks = ingress.value
        from_port   = ingress.key
        to_port     = ingress.key
        protocol    = "tcp"
      }
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_launch_template" "asg-lt" {
    name            = "ASLAWS-LT-ODIN-PROD-${var.name_suffix}"
    image_id                = var.v_ami
    vpc_security_group_ids  = [aws_security_group.asg_sg.id]
    
    block_device_mappings {
      device_name = "/dev/sda1"
      ebs {
        volume_size = 50
      }
    }

    block_device_mappings {
      device_name = "/dev/sdb"
      ebs {
        volume_size = 20
      }
    }

    iam_instance_profile {
      name = var.ec2_instance_profile_name
    }

    key_name = var.v_key_name

    tags  = var.v_tags

    user_data = base64encode(file(var.v_user_data_file))

  }

  resource "aws_autoscaling_group" "ag" {
    name = "ASLAWS-ASG-ODIN-PROD-${var.name_suffix}"
    desired_capacity    = var.v_desired_capacity
    min_size            = var.v_min_capacity
    max_size            = var.v_max_capacity
    vpc_zone_identifier = var.v_subnet_ids

    mixed_instances_policy {
      instances_distribution {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 25
        on_demand_allocation_strategy            = "prioritized"
      }
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.asg-lt.id
        }

        override {
          instance_type = "t3.medium"
        }

        override {
          instance_type = "t3a.medium"
        }
      }
    }
    
    target_group_arns = var.target_group_arns

    health_check_type         = "ELB"
    health_check_grace_period = 60
    force_delete              = true
    default_cooldown          = 300

    dynamic "tag" {
    for_each = var.asg_tags
    content {
      key                 = tag.value.key
      propagate_at_launch = tag.value.propagate_at_launch
      value               = tag.value.value
    }
   }
  }

  resource "aws_autoscaling_policy" "asg-policy" {
    autoscaling_group_name = aws_autoscaling_group.ag.name
    name                  = "TargetTrackingScaling"
    policy_type           = "TargetTrackingScaling"

    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }

      target_value = 40.0
    }

    estimated_instance_warmup = 60
  }
