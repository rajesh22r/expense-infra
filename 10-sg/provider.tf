terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket         = "raj-remotes-state"
    key            = "expense-sg"
    region         = "us-east-1"
    dynamodb_table = "raj-locking22"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}