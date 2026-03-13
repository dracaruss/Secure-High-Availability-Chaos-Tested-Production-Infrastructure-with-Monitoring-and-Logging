# =============================================================================
# providers.tf — AWS Provider & Terraform Version Constraints
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = var.aws_profile # Dynamically pulled from .tfvars

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Architect   = "Root Note Cyber"
    }
  }
}
