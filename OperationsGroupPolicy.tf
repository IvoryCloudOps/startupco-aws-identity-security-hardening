resource "aws_ssoadmin_permission_set_inline_policy" "operations_policy" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.operation_permission.arn

  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "Allowec2FullAccess",
        Effect   = "Allow",
        Action   = "ec2:*",
        Resource = "*"
      },
      {
        Sid      = "AllowcloudWatchFullAccess",
        Effect   = "Allow",
        Action   = "cloudwatch:*",
        Resource = "*"
      },
      {
        Sid      = "AllowcloudWatchLogsFullAccess",
        Effect   = "Allow",
        Action   = "logs:*",
        Resource = "*"
      },
      {
        Sid      = "AllowssmStartSession",
        Effect   = "Allow",
        Action   = "ssm:StartSession",
        Resource = "*"
      },
      {
        Sid      = "AllowssmTerminateSession",
        Effect   = "Allow",
        Action   = "ssm:TerminateSession",
        Resource = "*"
      },
      {
        Sid      = "AllowssmResumeSession",
        Effect   = "Allow",
        Action   = "ssm:ResumeSession",
        Resource = "*"
      },
      {
        Sid      = "AllowssmDescribeSessions",
        Effect   = "Allow",
        Action   = "ssm:DescribeSessions",
        Resource = "*"
      },
      {
        Sid      = "AllowssmRunCommand",
        Effect   = "Allow",
        Action   = ["ssm:SendCommand", "ssm:GetCommandInvocation", "ssm:DescribeInstanceInformation", "ssm:DescribeInstanceProperties"],
        Resource = "*"
      },
      {
        Sid      = "AllowrdsManage",
        Effect   = "Allow",
        Action   = "rds:*",
        Resource = "*"
      }
    ]
  })
}

# Account assignment for the operations group
resource "aws_ssoadmin_account_assignment" "operations" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.operation_permission.arn

  principal_id   = aws_identitystore_group.operations.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}