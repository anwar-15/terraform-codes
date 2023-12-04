resource "aws_s3_bucket" "bucket-name" {
    bucket = var.bucket-name
    tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "public-access" {
    bucket = aws_s3_bucket.bucket-name.bucket

    block_public_acls       = var.public-access-block[0]
    block_public_policy     = var.public-access-block[1]
    ignore_public_acls      = var.public-access-block[2]
    restrict_public_buckets = var.public-access-block[3]
}

resource "aws_s3_bucket_policy" "bucket-policy" {
	count = var.bucket-policy ? 1 : 0
    bucket = aws_s3_bucket.bucket-name.id
    policy = jsonencode({
		"Version": "2012-10-17",
		"Id": "PolicyForCloudFront",
		"Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.bucket-name.arn}/*"
        }
    ]
    })
}

resource "aws_s3_bucket_website_configuration" "static-website" {
	count = var.enable-static-website ? 1 : 0
	bucket = aws_s3_bucket.bucket-name.id
	index_document {
		suffix = var.website-document["suffix"]
	}
	error_document {
		key = var.website-document["key"]
	}
}

resource "aws_s3_bucket_versioning" "versioning" {
	bucket = aws_s3_bucket.bucket-name.bucket
	versioning_configuration {
		status = var.versioning-status
	}
}

resource "aws_s3_bucket_ownership_controls" "object-ownership" {
	bucket = aws_s3_bucket.bucket-name.bucket

	rule {
		object_ownership = "BucketOwnerPreferred"
	}
}
