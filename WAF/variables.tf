variable "name" {
  description = "Name of waf*"
  type = string
  default = ""
}

variable "description" {
  description = "Description about the waf*"
  type = string
  default = ""
}

variable "scope" {
  description = "scope of the WAF - REGIONAL OR CLOUDFRONT *"
  type = string
  default = "CLOUDFRONT"
}

variable "log-group-tags" {
  description = "Tags for the log-group"
  type = map
  default = {}
}