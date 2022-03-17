terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "3.42.0"
    }
  }

  backend "s3" {
    #bucket = "trackmarket-jenkins"
    #key = "ap-northeast-1.tfstate"
    #region = "ap-northeast-1"
  }
}