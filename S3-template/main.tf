provider "aws" {
  region = "ap-south-1"
}
module "s3-bucket" {
  source = "../S3"
  bucket-name = "my-bucket-testing-state-storage"
  versioning-status = "Enabled"
  # public-access-block = [true,true,true,true]
}

module "s3-bucket-policy" {
  source = "../s3-bucket-policy"
  bucket-name = "my-bucket-testing-state-storage"
  path = "terraform-state"
  depends_on = [ module.s3-bucket]
}

