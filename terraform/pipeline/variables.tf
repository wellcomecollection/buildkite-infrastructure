variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "repository_name" {
  type    = string
  default = ""

  description = "The name of the GitHub repository. If omitted, the name will be used."
}

variable "default_branch" {
  type    = string
  default = "main"
}

variable "pipeline_filename" {
  type = string
}

variable "trigger_builds_on_code_changes" {
  type    = bool
  default = true
}

variable "schedules" {
  type = list(object({
    label    = string
    cronline = string
  }))

  default = []
}
