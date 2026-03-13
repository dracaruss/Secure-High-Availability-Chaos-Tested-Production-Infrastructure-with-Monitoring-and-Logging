# =============================================================================
# data.tf — Data Sources (AMI Lookup, AZs, Account Info)
# =============================================================================

# Current AWS account & region info
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Discover available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Latest Amazon Linux 2023 AMI (used when var.ami_id is empty)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ELB service account for ALB access log bucket policy
data "aws_elb_service_account" "main" {}

# Resolve the AMI: explicit var takes precedence, else latest AL2023
locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id

  # Use only the requested number of AZs
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Auto-calculate subnet CIDRs if not provided
  # Public:  10.0.1.0/24, 10.0.2.0/24, ...
  # Private: 10.0.101.0/24, 10.0.102.0/24, ...
  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 1)
  ]
  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 101)
  ]

  name_prefix = "${var.project_name}-${var.environment}"
}
