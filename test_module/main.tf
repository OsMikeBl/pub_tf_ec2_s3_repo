terraform {
  required_version = ">= 1.0"
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

variable "mixed_object" {
  description = "Object with nested expressions"
  type = object({
    enabled   = bool
    timeout   = number
    endpoints = list(string)
    metadata = object({
      environment = string
      region      = string
    })
  })
}

# Resource that uses all variables
resource "null_resource" "test" {
  triggers = {
    string_expression = var.string_expression
    policy_config    = jsonencode(var.policy_config)
    array_value      = jsonencode(var.array_value)
    boolean_value    = tostring(var.boolean_value)
    number_value     = tostring(var.number_value)
    mixed_object     = jsonencode(var.mixed_object)
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

output "mixed_object" {
  value = var.mixed_object
}

output "version" {
  value = var.policy_config.version
}

output "rules_count" {
  value = length(var.policy_config.rules)
}
