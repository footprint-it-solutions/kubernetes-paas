resource "aws_kms_key" "hcvault" {
  description             = "this is used for vault auto unsealing"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
}

resource "aws_kms_key" "ebs_key" {
  description             = "this is used for ebs volumes"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
}

resource "aws_kms_alias" "hcvault_alias" {
  name          = "alias/hcvault"
  target_key_id = aws_kms_key.hcvault.key_id
}

resource "aws_kms_alias" "ebs_alias" {
  name          = "alias/ebs"
  target_key_id = aws_kms_key.ebs_key.key_id
}

output "kms_keys" {
  value = {
    "hcvault" = aws_kms_key.hcvault.key_id
    "ebs_key" = aws_kms_key.ebs_key.key_id
  }
}
