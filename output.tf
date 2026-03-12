# =============================================================================
# outputs.tf — Key Resource Identifiers & Endpoints
# =============================================================================

# ── Networking ───────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "Availability Zones in use"
  value       = local.azs
}

# ── Load Balancer ────────────────────────────────────────────────────────────

output "alb_dns_name" {
  description = "ALB DNS name (use this to access the application)"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID (for Route 53 alias records)"
  value       = aws_lb.main.zone_id
}

output "app_url" {
  description = "Full application URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${aws_lb.main.dns_name}"
}

# ── Compute ──────────────────────────────────────────────────────────────────

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.app.id
}

output "ami_id" {
  description = "AMI ID in use"
  value       = local.ami_id
}

# ── Security ─────────────────────────────────────────────────────────────────

output "ec2_role_arn" {
  description = "IAM role ARN attached to EC2 instances"
  value       = aws_iam_role.ec2_app.arn
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "App instances security group ID"
  value       = aws_security_group.app.id
}

# ── Monitoring ───────────────────────────────────────────────────────────────

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${local.name_prefix}-overview"
}

output "alb_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  value       = aws_s3_bucket.alb_logs.id
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  value       = aws_sns_topic.alarms.arn
}
