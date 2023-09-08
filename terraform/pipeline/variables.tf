variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
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

variable "schedules" {
  type = list(object({
    label    = string
    cronline = string
  }))

  default = []
}
