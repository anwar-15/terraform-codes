provider "aws" {
  region = "us-east-1"
}

module "waf" {
  source = "../WAF"
  name = "waf-terraform-test"
  description = "testing terraform waf"
  scope = "CLOUDFRONT"
  log-group-tags = {
    Purpose = "Test the logging tags"
  }
}