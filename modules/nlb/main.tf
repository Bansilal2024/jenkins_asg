data "aws_s3_bucket" "logging_bucket" {
  bucket = "bansi-b3"
}

output "aws_s3_bucket_id"{
  value = data.aws_s3_bucket.logging_bucket.id
}
# modules/nlb/network_load_balancer.tf
resource "aws_security_group" "nlb_sg" {
  name   = "nlb-sg"
  vpc_id = var.vpc_id

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

resource "aws_lb" "nlb" {
  name                      = "ASL-AWS-PROD-ODIN-${var.name_suffix}"
  internal                  = true
  load_balancer_type        = "network"
  enable_deletion_protection = false
  security_groups           = [aws_security_group.nlb_sg.id]
  subnets                   = var.v_subnet_ids

  enable_cross_zone_load_balancing = true

  # access_logs {
  #  bucket  = data.aws_s3_bucket.logging_bucket.id
  #  prefix  = "test-lb"
  #  enabled = true
  #}

  tags = var.v_tags

}
