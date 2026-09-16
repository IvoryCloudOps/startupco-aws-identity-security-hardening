resource "aws_secretsmanager_secret" "startupco_app_secret" {
  name        = "startupco_app_secret"
  description = "Secret for StartupCo application"
  kms_key_id  = aws_kms_key.startupco_security_key.arn
}

resource "aws_secretsmanager_secret_version" "startupco_app_secret_value" {
  secret_id     = aws_secretsmanager_secret.startupco_app_secret.id
  secret_string = var.startupco_database_secret
}