resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = var.bucket-name
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.bucket-name}"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::${var.bucket-name}/*",
      "Principal": "*"
    }
  ]
  })
}