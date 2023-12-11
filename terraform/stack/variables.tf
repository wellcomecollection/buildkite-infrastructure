variable "name" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "min_workers" {
  type    = number
  default = 0
}

variable "max_workers" {
  type = number
}

variable "elastic_ci_stack_version" {
  type = string
}

variable "extra_parameters" {}

variable "network_config" {}

variable "ci_agent_role_name" {
  type = string
}

variable "disk_size" {
  type = string

  validation {
    condition     = can(regex("^\\d+ GB$", var.disk_size))
    error_message = "The disk_size must be a string like '10 GB' or '20 GB'."
  }
}

variable "secrets_bucket_id" {
  type = string
}

variable "elastic_ci_stack_templates_bucket" {
  type = string
}
