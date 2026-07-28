# ──────────────────────────────────────────────────────────
# MONITORING MODULE
# Creates: SNS topic, SNS email subscription,
#          CloudWatch CPU alarm
# ──────────────────────────────────────────────────────────

# ── SNS Topic ─────────────────────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts-${var.environment}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alerts-${var.environment}"
  })
}

# ── SNS Email Subscription ────────────────────────────────
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ── CloudWatch CPU Alarm ──────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.project_name}-ec2-cpu-alarm-${var.environment}"
  alarm_description   = "EC2 CPU utilisation above 80% for 10 consecutive minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-cpu-alarm-${var.environment}"
  })
}
