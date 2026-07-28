output "s3_bucket_id" {
  value = aws_s3_bucket.app_assets.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.app_assets.arn
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

output "rds_db_name" {
  value = aws_db_instance.postgres.db_name
}
