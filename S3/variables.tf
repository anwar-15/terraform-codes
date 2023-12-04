variable "bucket-name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "versioning-status" {
  description = "Bucket Versioning Status *"
  type = string
  default = "Disabled"
}

#defaults to false
variable "public-access-block" {
    description = "bool values to block public access to bucket"
    type = list(bool)
    default = [
        false, #block_public_acls
        false, #block_public_policy
        false, #ignore_public_acls
        false  #restrict_public_buckets
    ]   
}

variable "bucket-policy" {
  type = bool
  default = false
}

variable "enable-static-website" {
  type    = bool
  default = false
}

variable "website-document" {
    description = "static website configuration"
    type = map
    default = {
        "suffix" = "index.html"
        "key" = "error.html"
    }
}