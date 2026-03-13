# =============================================================================
# compute.tf — Launch Template, Auto Scaling Group, Scaling Policies
# =============================================================================

# ── Launch Template ──────────────────────────────────────────────────────────

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = local.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_app.arn
  }

  # Only attach key pair if one is specified
  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  vpc_security_group_ids = [aws_security_group.app.id]

  # Encrypted root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = var.root_volume_encrypted
      delete_on_termination = true
    }
  }

  # IMDSv2 enforced (no v1 — prevents SSRF token theft)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Enable detailed monitoring for 1-minute CloudWatch metrics
  monitoring {
    enabled = true
  }

  # User data: install CloudWatch agent + bootstrap app
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
    region       = var.aws_region
    log_group    = aws_cloudwatch_log_group.app.name
    app_port     = var.app_port
    project_name = var.project_name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-app"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${local.name_prefix}-app-vol"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group ───────────────────────────────────────────────────────

resource "aws_autoscaling_group" "app" {
  name_prefix         = "${local.name_prefix}-asg-"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]

  # Health check via ALB (not just EC2 status)
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Rolling update settings
  default_instance_warmup = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Spread instances across AZs evenly
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Scaling Policies ─────────────────────────────────────────────────────────

# CPU-based target tracking
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${local.name_prefix}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value     = var.cpu_target_value
    disable_scale_in = false
  }
}

# ALB request count per target (scale on traffic)
resource "aws_autoscaling_policy" "request_count" {
  name                   = "${local.name_prefix}-request-count"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.app.arn_suffix}"
    }
    target_value     = 1000 # requests per target per minute
    disable_scale_in = false
  }
}
