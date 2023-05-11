terraform {
  backend "s3" {
    bucket         = "BUCKET_NAME"
    key            = "account.tfstate"
    dynamodb_table = "TABLE_NAME"
    region         = "eu-west-2"
  }
}
