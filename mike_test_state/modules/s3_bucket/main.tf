variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "frontend-link-demo-bucket"
  }
}

output "arn" {
  value = aws_s3_bucket.this.arn
}
