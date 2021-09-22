resource "aws_s3_bucket" "media-bucket" {
  bucket = "media-wp-assign-bucket"
  acl    = "private"

  tags = {
    Name = "media-wp-bucket"
  }
}

resource "aws_s3_bucket" "wp-assign-state-bckt" {
  bucket = "wp-assign-state-bckt"
  acl    = "private"

  tags = {
    Name = "media-wp-bucket"
  }
}