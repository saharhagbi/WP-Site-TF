output "public-ip-site" {
  description = "WordPress Site URL"
  value       = join("", ["http://", aws_instance.wp-site.public_ip])
}

output "rds-endpoint" {
  description = "Rds Endpoint"
  value       = aws_db_instance.wp-db.endpoint
}

output "media-bucket-name" {
  description = "s3 bucket name to store media in it"
  value       = aws_s3_bucket.media-bucket.id
}