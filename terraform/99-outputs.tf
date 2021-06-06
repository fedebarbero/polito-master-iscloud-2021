output "rds_username" {
  value = var.rds_username
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = module.db.this_rds_cluster_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = module.db.this_rds_cluster_reader_endpoint
}

output "rds_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.db.this_rds_cluster_database_name
}

output "rds_cluster_master_password" {
  description = "The master password"
  value       = module.db.this_rds_cluster_master_password
  sensitive   = true
}

output "alb_endpoint" {
  description = "The ALB endpoint"
  value       = module.alb.lb_dns_name
}