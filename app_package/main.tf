variable "name" {
  description = "Name of the application"
  type        = string
}

variable "port" {
  description = "Port for the application"
  type        = number
  default     = 8080
}

variable "network_id" {
  description = "ID of the VPC from network package (optional for testing)"
  type        = string
  default     = ""
}

# Simple resource for testing skip logic - doesn't require network_id
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${coalesce(var.name, "default")}-app-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = var.name
    Port        = tostring(var.port)
    NetworkId   = var.network_id != "" ? var.network_id : "not-provided"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

output "id" {
  description = "ID of the created application resource"
  value       = aws_s3_bucket.app_bucket.id
}

output "name" {
  description = "Name of the application"
  value       = var.name
}
