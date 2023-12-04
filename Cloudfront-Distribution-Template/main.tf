provider "aws" {
    region = "ap-south-1"
}

module "S3-origin-bucket" {
    source = "../S3"

    bucket-name = "testweb.ai.123456789"
    enable-static-website = true
    versioning-status = "Enabled"
    bucket-policy = true
    tags = {
        Environment = "Test"
        Purpose = "Static Website"
    }
}

module "S3-logging-bucket" {
    source = "../S3"

    bucket-name = "testweb.ai.logs.123456789"
    enable-static-website = false
    bucket-policy = false
    tags = {
      Environment = "Test"
      Purpose = "Logging Cloudfront Distribution"
    }
    public-access-block = [true, true, true, true]
}

module "Cloudfront" {
    source = "../Cloudfront" 
    origin-name = "testweb.ai.123456789"
    logging-bucket-name = "testweb.ai.logs.123456789"
    description = "Cloudfront distribution for testweb.ai"
    tags = {
        Environment = "Test"
        Purpose = "Cloudfront Distribution satic website"
    }

    depends_on = [module.S3-origin-bucket, module.S3-logging-bucket]
}
