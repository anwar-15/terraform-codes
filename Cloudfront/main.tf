data "aws_s3_bucket" "origin-bucket" {
  bucket = var.origin-name
}

data "aws_s3_bucket" "logging-bucket" {
  bucket = var.logging-bucket-name
}

locals {
  s3_origin_id = var.origin-name
}

resource "aws_cloudfront_origin_access_control" "OAC" {
  name                              = "Origin-Access-Control"
  description                       = "OAC for s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = data.aws_s3_bucket.origin-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.OAC.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.description
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = data.aws_s3_bucket.logging-bucket.bucket_regional_domain_name
    prefix          = "cloudfront-logs/"
  }

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors-security-header-policy.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = var.custom-certificate
  }
  depends_on = [
    data.aws_s3_bucket.origin-bucket,
    data.aws_s3_bucket.logging-bucket,
    aws_cloudfront_response_headers_policy.cors-security-header-policy 
  ]

}

resource "aws_cloudfront_response_headers_policy" "cors-security-header-policy" {
  name    = "CORS-and-SecurityHeaders"
  comment = "CORS and Security-Headers for ${local.s3_origin_id}"

  cors_config {
    access_control_allow_credentials = false
    origin_override = false
    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["ALL"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    access_control_expose_headers {
      items = ["*"]
    }
  }

  security_headers_config {
    content_type_options {
      override = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      override                   = false
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = false
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = false
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
  }
  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      override = false
      value    = var.permission-policy
    }
  }
}

