resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "aurora5.6"
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "rds-cluster-pg"
  family      = "aurora5.6"
  description = "RDS default cluster parameter group"
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = "wordpress-workshop-aurora-rds"
  engine         = "aurora"
  engine_version = "5.6.10a"
  instance_type  = "db.t3.small"

  username               = var.rds_username
  create_random_password = true
  database_name          = var.rds_database_name

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.intra_subnets

  replica_count          = var.rds_replica_count
  vpc_security_group_ids = [aws_security_group.data_layer_sg.id]

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.default.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
}

resource "random_pet" "dbpassword_pet" {

}

resource "aws_secretsmanager_secret" "db-master-password" {
  name                    = "rds-master-password-${random_pet.dbpassword_pet.id}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db-master-password-value" {
  secret_id     = aws_secretsmanager_secret.db-master-password.id
  secret_string = module.db.this_rds_cluster_master_password
}

resource "aws_elasticache_parameter_group" "wp_memcached_cluster_pg" {
  name   = "wp-memcached-cluster-pg"
  family = "memcached1.6"
}

resource "aws_elasticache_subnet_group" "wp_memcached_cluster_subg" {
  name       = "wp-memcached-cluster-subg"
  subnet_ids = module.vpc.intra_subnets
}

resource "aws_elasticache_cluster" "wp_memcached_cluster" {
  cluster_id           = "wp-memcached-cluster-example"
  engine               = "memcached"
  engine_version       = "1.6.6"
  node_type            = var.ec_instance_type
  num_cache_nodes      = var.ec_node_count
  parameter_group_name = aws_elasticache_parameter_group.wp_memcached_cluster_pg.name
  port                 = 11211
  subnet_group_name    = aws_elasticache_subnet_group.wp_memcached_cluster_subg.name
  security_group_ids   = [aws_security_group.cache_layer_sg.id]
}

resource "aws_efs_file_system" "wp_efs" {
  creation_token = "wp-efs"
  encrypted      = true
  tags = {
    Name = "wp-efs"
  }
}

resource "aws_efs_mount_target" "wp_efs_mt" {
  count           = length(module.vpc.intra_subnets)
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = module.vpc.intra_subnets[count.index]
  security_groups = [aws_security_group.efs_layer_sg.id]
}

resource "aws_s3_bucket" "alb_access_log" {
  bucket = "wp-alb-logs-adskjfhasd129"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  force_destroy = true

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::156460612806:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::wp-alb-logs-adskjfhasd129/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::wp-alb-logs-adskjfhasd129/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::wp-alb-logs-adskjfhasd129"
    }
  ]
}
EOF
}
