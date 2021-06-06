
terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "terraform-aws-backend-f2awcwvkfb"
    key            = "state.tfstate"
    dynamodb_table = "terraform-aws-backend-f2awcwvkfb"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
    random = {
      source = "hashicorp/random"
    }
    // template = {
    //   source = "hashicorp/template"
    // }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = var.general_tags
  }
}