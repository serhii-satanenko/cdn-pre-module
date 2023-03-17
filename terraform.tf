terraform {
  backend "s3" {
    bucket  = "serhii-satanenko-terraform-state"
    key     = "work-terraform/cdn-final/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58.0"
    }
  }
}

provider "aws" {
  region  = var.region
}

variable "region" {
  default = "eu-central-1"
}