# Terraform configuration

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = "GlobalLogicServer"
  instance_count = 2
 
  #This AMI belongs to ubuntu server.    
  ami                    = "ami-013f17f36f8b1fefb"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids             = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]] 

  tags = {
    Owner   = "GlobalLogic"
    Environment = "Web"
  }
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "GLPublicWebServerEndpoint"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  target_groups = [
    {
      name_prefix      = "GLWeb-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Web"
  }
}

resource "aws_lb_target_group_attachment" "GLServer1" {
  target_group_arn = module.nlb.target_group_arns[0]
  target_id        = module.ec2_instances.id[0]
  port             = 80
}

resource "aws_lb_target_group_attachment" "GLServer2" {
  target_group_arn = module.nlb.target_group_arns[0]
  target_id        = module.ec2_instances.id[1]
  port             = 80
}

