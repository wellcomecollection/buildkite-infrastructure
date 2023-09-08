variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "default_branch" {
  type    = string
  default = "main"
}

variable "pipeline_filename" {
  type = string
}
