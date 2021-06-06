module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wordpress-workshop"
  cidr = "192.168.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  intra_subnets   = ["192.168.4.0/24", "192.168.5.0/24"]
  private_subnets = ["192.168.2.0/24", "192.168.3.0/24"]
  public_subnets  = ["192.168.0.0/24", "192.168.1.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
}

resource "aws_security_group" "cache_layer_sg" {
  name        = "cache-layer-sg"
  description = "Cache layer SG"
  vpc_id      = module.vpc.vpc_id

  egress {
    description     = "MySQL out"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.data_layer_sg.id]
  }
}

resource "aws_security_group_rule" "app_cache_layer_sg_rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_layer_sg.id
  security_group_id        = aws_security_group.cache_layer_sg.id
}

resource "aws_security_group" "data_layer_sg" {
  name        = "data_layer_sg"
  description = "Data layer SG"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "data_app_layer_sg_rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_layer_sg.id
  security_group_id        = aws_security_group.data_layer_sg.id
}

resource "aws_security_group_rule" "data_cache_layer_sg_rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cache_layer_sg.id
  security_group_id        = aws_security_group.data_layer_sg.id
}

resource "aws_security_group" "app_layer_sg" {
  name        = "app_layer_sg"
  description = "App layer SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTPS from ELB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_layer_sg.id]
  }

  ingress {
    description     = "HTTP from ELB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_layer_sg.id]
  }

  egress {
    description     = "MySQL out"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.data_layer_sg.id]
  }

  egress {
    description     = "EFS out"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.efs_layer_sg.id]
  }

  egress {
    description     = "Cache out"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.cache_layer_sg.id]
  }

  egress {
    description = "HTTP out"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "HTTPS out"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "NTP out"
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "NTP out"
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS out"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS out"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_layer_sg" {
  name        = "efs-layer-sg"
  description = "EFS layer SG"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "app_efs_layer_sg_rule" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_layer_sg.id
  security_group_id        = aws_security_group.efs_layer_sg.id
}

resource "aws_security_group" "alb_layer_sg" {
  name        = "alb-layer-sg"
  description = "ALB layer SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP in"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS in"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "app_alb_layer_sg_rule" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_layer_sg.id
  security_group_id        = aws_security_group.alb_layer_sg.id
}
resource "aws_security_group_rule" "app_alb_layer_sg_rule2" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_layer_sg.id
  security_group_id        = aws_security_group.alb_layer_sg.id
}

resource "aws_iam_instance_profile" "wp_profile" {
  name = "wp-profile"
  role = aws_iam_role.wp_role.name
}

resource "aws_iam_role" "wp_role" {
  name = "wp-role"
  path = "/"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}