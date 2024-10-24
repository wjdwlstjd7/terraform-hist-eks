data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpc" "vpc" {
  id = var.vpc_id
}
terraform {
  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      version = ">= 3.55.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  # Default Region
  region = var.aws_default_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}