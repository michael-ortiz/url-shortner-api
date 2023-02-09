# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "michael"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}