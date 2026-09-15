resource "aws_ssoadmin_permission_set_inline_policy" "developer_policy" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.developer_permission.arn

  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowS3ReadWriteObject",
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = "${aws_s3_bucket.application_data.arn}/*"
      },
      {
        Sid      = "AllowS3ListBucket",
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = aws_s3_bucket.application_data.arn
      },
      {
        Sid      = "AllowlogsDescribeLogGroups",
        Effect   = "Allow",
        Action   = "logs:DescribeLogGroups",
        Resource = "*"
      },
      {
        Sid      = "AllowlogsDescribeLogStreams",
        Effect   = "Allow",
        Action   = "logs:DescribeLogStreams",
        Resource = "*"
      },
      {
        Sid      = "AllowlogsReadLogEvents",
        Effect   = "Allow",
        Action   = ["logs:GetLogEvents", "logs:FilterLogEvents"],
        Resource = "*"
      },
      {
        Sid      = "Allowec2DescribeInstances",
        Effect   = "Allow",
        Action   = "ec2:DescribeInstances",
        Resource = "*"
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
        Sid      = "Allowec2ManageAppServers",
        Effect   = "Allow",
        Action   = ["ec2:StartInstances", "ec2:StopInstances", "ec2:RebootInstances"],
        Resource = "arn:aws:ec2:*:*:instance/*",
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Role" = "app-server"
          }
        }
      }
    ]
  })
}

# Account assignment for the developers group
data "aws_caller_identity" "current" {}

resource "aws_ssoadmin_account_assignment" "developers" {
  instance_arn       = data.aws_ssoadmin_instances.startupco.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.developer_permission.arn

  principal_id   = aws_identitystore_group.developers.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

data "aws_region" "current" {}