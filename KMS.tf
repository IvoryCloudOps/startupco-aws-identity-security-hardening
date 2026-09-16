resource "aws_kms_key" "startupco_security_key" {
  description             = "KMS key for StartupCo security resources"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "startupco_security_key" {
  name          = "alias/startupco_security_key"
  target_key_id = aws_kms_key.startupco_security_key.id
}

