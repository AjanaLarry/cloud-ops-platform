output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu.alarm_name
}
