terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.region
}

# ─────────────────────────────
# INPUT VARIABLES
# ─────────────────────────────

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

# ─────────────────────────────
# DATA SOURCES
# ─────────────────────────────

# Automatically find the latest Ubuntu 22.04 LTS AMI for the selected region
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ❌ Non-AWS data source (for testing FE logic)
data "aws_caller_identity" "current" {}

# ─────────────────────────────
# RESOURCES
# ─────────────────────────────

# ✅ AWS resource (FE should generate link)
module "ec2_instance" {
  source        = "./modules/ec2_instance"
  instance_type = var.instance_type
  ami_id        = data.aws_ami.ubuntu_latest.id
}

# ✅ AWS resource (FE should generate link)
module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}

# ❌ Non-AWS resource (FE should NOT generate link)
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo 'Not an AWS resource - no ARN, no link'"
  }
}

# ─────────────────────────────
# OUTPUTS
# ─────────────────────────────

# AWS Resources (FE should hyperlink)
output "ec2_arn" {
  description = "ARN of the created EC2 instance"
  value       = module.ec2_instance.arn
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3_bucket.arn
}

# Non-AWS or data-only items (FE should ignore)
output "non_aws_id" {
  description = "ID of null_resource (no ARN)"
  value       = null_resource.example.id
}

output "caller_identity" {
  description = "AWS account info (for testing only)"
  value = {
    account_id = data.aws_caller_identity.current.account_id
    arn         = data.aws_caller_identity.current.arn
    user_id     = data.aws_caller_identity.current.user_id
  }
}
