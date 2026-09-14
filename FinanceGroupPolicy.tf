# Finance group permissions
resource "aws_ssoadmin_permission_set_inline_policy" "finance_policy" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.finance_permission.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "AllowBudgetsView"
        Effect   = "Allow"
        Action   = "budgets:ViewBudget"
        Resource = "*"
      },
      {
        Sid      = "AllowBudgetsModify"
        Effect   = "Allow"
        Action   = "budgets:ModifyBudget"
        Resource = "*"
      },
      {
        Sid    = "AllowCostExplorerReadOnly"
        Effect = "Allow"

        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostAndUsageWithResources",
          "ce:GetCostCategories",
          "ce:GetDimensionValues",
          "ce:GetCostForecast",
          "ce:GetTags",
          "ce:GetUsageForecast",
          "ce:DescribeReport"
        ]

        Resource = "*"
      },
      {
        Sid      = "AllowEC2Describe"
        Effect   = "Allow"
        Action   = "ec2:Describe*"
        Resource = "*"
      },
      {
        Sid      = "AllowS3List"
        Effect   = "Allow"
        Action   = "s3:List*"
        Resource = "*"
      },
      {
        Sid      = "AllowS3GetBucket"
        Effect   = "Allow"
        Action   = "s3:GetBucket*"
        Resource = "*"
      },
      {
        Sid      = "AllowRDSDescribe"
        Effect   = "Allow"
        Action   = "rds:Describe*"
        Resource = "*"
      }
    ]
  })
}


# Account assignment for the finance group
resource "aws_ssoadmin_account_assignment" "finance" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.finance_permission.arn

  principal_id   = aws_identitystore_group.finance.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}