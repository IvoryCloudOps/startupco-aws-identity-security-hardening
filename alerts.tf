resource "aws_sns_topic" "startupco_security_alerts" {
  name = "startupco_security_alerts"
}

resource "aws_sns_topic_subscription" "startupco_security_alerts_subscription" {
  topic_arn = aws_sns_topic.startupco_security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "config_compliance_change" {
  name        = "config_compliance_change"
  description = "Triggered when AWS Config compliance changes"

  event_pattern = <<PATTERN
{
  "source": ["aws.config"],
  "detail-type": ["Config Rules Compliance Change"],
  "detail": {
    "configRuleName": ["s3-bucket-level-public-access-prohibited"],
    "newEvaluationResult": {
      "complianceType": ["NON_COMPLIANT"]
    }
  }
}
PATTERN

}

resource "aws_cloudwatch_event_target" "config_compliance_change_target" {
  rule      = aws_cloudwatch_event_rule.config_compliance_change.name
  target_id = "config_compliance_change_target"
  arn       = aws_sns_topic.startupco_security_alerts.arn
}



resource "aws_sns_topic_policy" "allow_eventbridge" {
  arn    = aws_sns_topic.startupco_security_alerts.arn
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.startupco_security_alerts.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.config_compliance_change.arn}"
        }
      }
    }
  ]
}
POLICY
}

