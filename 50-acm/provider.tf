terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.0"
    }
  }

 backend "s3" {
    bucket         = "raj22-remote-state-dev"
    key            = "expenseacm"
    region         = "us-east-1"
    dynamodb_table = "raj-locking-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}