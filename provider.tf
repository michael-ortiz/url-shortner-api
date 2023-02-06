# Configure the AWS Provider
provider "aws" {
  region = "<YOUR_AWS_REGION>"
  profile = "<YOUR_AWS_CONFIGURE_PROFILE>"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}