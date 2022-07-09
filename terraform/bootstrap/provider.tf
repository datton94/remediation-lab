provider "aws" {
  region  = "ap-southeast-1"
  profile = "devops"
}

terraform {
  backend "s3" {
    bucket         = "terraform-boostrap"
    key            = "bootstrap.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-boostrap"
    profile        = "devops"
    encrypt        = true
    kms_key_id     = "4ccd498b-ab0b-47c8-ba95-af00c14fd8ee"
  }
}
