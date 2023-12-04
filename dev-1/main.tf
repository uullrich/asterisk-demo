terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "uullrich-tf"
    key            = "state/asterisk-demo/dev.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "uullrich-tf"
  }
}
