terraform {
  backend "s3" {
    bucket = "my-bucket-testing-state-storage"
    key    = "terraform-state"
    region = "ap-south-1"
  }
}