terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.39.0"
    }
  }
}
provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "fpmlabs"
}

resource "random_string" "random" {
  length  = 5
  special = false
}

resource "aws_s3_bucket" "b" {
  bucket = "tf-state-${lower(random_string.random.id)}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "tf-state"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_state_lock" {
  name         = "tf-state-${lower(random_string.random.id)}"
  billing_mode = "PAY_PER_REQUEST"

  # https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table
  hash_key = "LockID"


  lifecycle {
    ignore_changes = [
      billing_mode,
      read_capacity,
      write_capacity,
    ]
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
