provider "aws" {
  region  = "eu-west-2"
  version = "~>2.63"
}

terraform {
  backend "s3" {
    bucket = "ecsfargateappbucket01"
    key    = "state/terraform.tfstate"
    region = "eu-west-2"
  }
}