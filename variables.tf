# =============================================================================
# variables.tf — Configurable Inputs
# =============================================================================

# ── Project Metadata ─────────────────────────────────────────────────────────

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_profile" {
  description = "The AWS CLI profile to use for authentication"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The AWS region called"
  type        = string
  default     = "default"
}


# ── Networking ───────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to use (min 2)"
  type        = number
  default     = 2
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "az_count must be between 2 and 4."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ). If empty, auto-calculated."
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ). If empty, auto-calculated."
  type        = list(string)
  default     = []
}

# ── Compute ──────────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "EC2 instance type for the application servers"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Specific AMI ID to use. If empty, latest Amazon Linux 2023 is selected."
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to disable SSH."
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root EBS volume"
  type        = bool
  default     = true
}

# ── Application ──────────────────────────────────────────────────────────────

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path for ALB health checks"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Seconds between ALB health checks"
  type        = number
  default     = 30
}

variable "health_check_healthy_threshold" {
  description = "Consecutive successes before marking healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Consecutive failures before marking unhealthy"
  type        = number
  default     = 3
}

# ── TLS / Domain ─────────────────────────────────────────────────────────────

variable "domain_name" {
  description = "Domain name for the ACM certificate (e.g., app.example.com). Leave empty to skip ACM."
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for DNS validation. Required if domain_name is set."
  type        = string
  default     = ""
}

# ── Monitoring ───────────────────────────────────────────────────────────────

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Days to retain CloudWatch log groups"
  type        = number
  default     = 90
}

variable "access_log_retention_days" {
  description = "Days before ALB access logs transition to Glacier in S3"
  type        = number
  default     = 90
}

# ── Scaling Policy ───────────────────────────────────────────────────────────

variable "cpu_target_value" {
  description = "Target average CPU utilization (%) for scaling policy"
  type        = number
  default     = 60
}
