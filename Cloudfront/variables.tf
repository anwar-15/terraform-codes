variable "origin-name" {
  description = "Name of the cloudfront origin *"
  type = string
  default = ""
}

variable "logging-bucket-name" {
  description = "Name of the logging-bucket for logs *"
  type = string
  default = ""
}

variable "aliases" {
  description = "List of all aliases to be provided"
  type = list(string)
  default = null
}

variable "description" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to bucket *"
  type        = map(string)
  default     = {}
}

variable "permission-policy" {
  type    = string
  default = "geolocation=(), microphone=()"
}

variable "custom-certificate" {
  type = string
  default = null
}