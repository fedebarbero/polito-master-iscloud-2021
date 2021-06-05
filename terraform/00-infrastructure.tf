module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  intra_subnets = ["192.168.4.0/24", "192.168.5.0/24"]
  private_subnets = ["192.168.2.0/24", "192.168.3.0/24"]
  public_subnets  = ["192.168.0.0/24", "192.168.1.0/24"]

  enable_nat_gateway = true
  single_nat_gateway  = false 
  #Cost optimization

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}