variable "general_tags" {
  default = {
    Terraform   = "true"
    Environment = "prod"
  }
}

variable "rds_replica_count" {}
variable "rds_instance_type" {}
variable "rds_username" {
  default = "wpadmin"
}
variable "rds_database_name" {
  default = "wordpress"
}
variable "ec_instance_type" {}
variable "ec_node_count" {}
variable "asg_instance_type" {}