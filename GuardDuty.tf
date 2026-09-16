resource "aws_guardduty_detector" "startupco_guardduty" {
  enable = true
}

resource "aws_securityhub_account" "startupco_securityhub" {
  depends_on = [
    aws_guardduty_detector.startupco_guardduty
  ]
}