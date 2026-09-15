resource "aws_ssoadmin_permission_set_inline_policy" "analyst_policy" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.analyst_permission.arn

  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "Allows3GetObject",
        Effect   = "Allow",
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.application_data.arn}/*"
      },
      {
        Sid      = "Allows3ListBucket",
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = aws_s3_bucket.application_data.arn
      },
      {
        Sid      = "AllowS3ConsoleBucketList",
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      },
      {
        Sid      = "AllowS3BucketLocation",
        Effect   = "Allow",
        Action   = "s3:GetBucketLocation",
        Resource = aws_s3_bucket.application_data.arn
      },
      {
        Sid      = "AllowrdsDescribeDBInstances",
        Effect   = "Allow",
        Action   = "rds:DescribeDBInstances",
        Resource = "*"
      },
      {
        Sid      = "AllowrdsDescribeDBClusters",
        Effect   = "Allow",
        Action   = "rds:DescribeDBClusters",
        Resource = "*"
      }
    ]
  })
}

# Account assignment for the analysts group
resource "aws_ssoadmin_account_assignment" "analysts" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.analyst_permission.arn

  principal_id   = aws_identitystore_group.analysts.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}
