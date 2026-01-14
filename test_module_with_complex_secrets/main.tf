terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

variable "string_expression" {
  description = "String prop with expression"
  type        = string
}

variable "policy_config" {
  description = "Policy configuration object with rules and version"
  type = object({
    rules = list(object({
      action   = string
      resource = string
    }))
    version = string
  })
}

variable "array_value" {
  description = "Array prop value"
  type        = list(string)
}

variable "boolean_value" {
  description = "Boolean prop value"
  type        = bool
}

variable "number_value" {
  description = "Number prop value"
  type        = number
}

variable "mixed_object_with_secrets" {
  description = "Object with nested expressions and secrets"
  type = object({
    enabled   = bool
    timeout   = number
    endpoints = list(string)
    metadata = object({
      environment = string
      region      = string
    })
    my_secret1 = string
    my_secret2 = object({
      username = string
      password = string
    })
  })
  sensitive = true
}

# Resource that uses all variables including secrets
resource "null_resource" "test" {
  triggers = {
    string_expression          = var.string_expression
    policy_config             = jsonencode(var.policy_config)
    array_value               = jsonencode(var.array_value)
    boolean_value             = tostring(var.boolean_value)
    number_value              = tostring(var.number_value)
    mixed_object_with_secrets = jsonencode(var.mixed_object_with_secrets)
    # Separate secret references for better tracking
    secret1_hash = md5(var.mixed_object_with_secrets.my_secret1)
    secret2_hash = md5(jsonencode(var.mixed_object_with_secrets.my_secret2))
  }
}

output "string_expression" {
  value = var.string_expression
}

output "policy_config" {
  value = var.policy_config
}

output "array_value" {
  value = var.array_value
}

output "boolean_value" {
  value = var.boolean_value
}

output "number_value" {
  value = var.number_value
}

output "mixed_object_metadata" {
  description = "Non-sensitive metadata from mixed object"
  value = {
    enabled     = var.mixed_object_with_secrets.enabled
    timeout     = var.mixed_object_with_secrets.timeout
    endpoints   = var.mixed_object_with_secrets.endpoints
    environment = var.mixed_object_with_secrets.metadata.environment
    region      = var.mixed_object_with_secrets.metadata.region
  }
}

output "secret1_exists" {
  description = "Check if secret1 is provided"
  value       = length(var.mixed_object_with_secrets.my_secret1) > 0
}

output "secret2_username" {
  description = "Username from secret2 (not the actual password)"
  value       = var.mixed_object_with_secrets.my_secret2.username
  sensitive   = true
}

output "version" {
  value = var.policy_config.version
}

output "rules_count" {
  value = length(var.policy_config.rules)
}

# Output with hashes of secrets for verification without exposing them
output "secrets_hash" {
  description = "MD5 hashes of secrets for verification"
  value = {
    secret1_hash = md5(var.mixed_object_with_secrets.my_secret1)
    secret2_hash = md5(jsonencode(var.mixed_object_with_secrets.my_secret2))
  }
}
