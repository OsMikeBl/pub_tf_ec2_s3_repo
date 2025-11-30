variable "name" {
  description = "Name of the network/VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the network"
  type        = string
  default     = "10.0.0.0/16"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.name
  }
}

output "id" {
  description = "ID of the created VPC"
  value       = aws_vpc.vpc.id
}

output "cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

