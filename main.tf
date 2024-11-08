terraform {
  backend "remote" {
    organization = "learn-terraform-inseo"
    workspaces {
      name = "Auction-Workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = var.region
}