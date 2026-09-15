data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ------------------------------------------------------------
# Amazon Linux 2023
# ------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ------------------------------------------------------------
# EC2 Security Group
#
# No inbound rules are required for this project.
# ------------------------------------------------------------

resource "aws_security_group" "test_instance" {
  name        = "startupco-security-test"
  description = "Security group for StartupCo IAM testing"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ------------------------------------------------------------
# EC2 role for Systems Manager
#
# This is the EC2 machine identity.
# It is separate from employee Identity Center permissions.
# ------------------------------------------------------------

resource "aws_iam_role" "ec2_ssm" {
  name = "startupco-test-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "startupco-test-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}


# ------------------------------------------------------------
# Minimal EC2 test resource
# ------------------------------------------------------------

resource "aws_instance" "test_instance" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  subnet_id = sort(data.aws_subnets.default.ids)[0]

  vpc_security_group_ids = [
    aws_security_group.test_instance.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  tags = {
    Name        = "startupco-security-test"
    Environment = "production"
    Role        = "app-server"
  }

  lifecycle {
    ignore_changes = [ami]
  }

}


# ------------------------------------------------------------
# Application-data S3 bucket
# ------------------------------------------------------------

resource "aws_s3_bucket" "application_data" {
  bucket = var.application_bucket_name

  tags = {
    Name        = "StartupCo Application Data"
    Environment = "production"
  }
}


resource "aws_s3_bucket_public_access_block" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ------------------------------------------------------------
# Sample object for permission testing
# ------------------------------------------------------------

resource "aws_s3_object" "sample_data" {
  bucket = aws_s3_bucket.application_data.id
  key    = "application-data/sample.txt"

  content = <<EOF
StartupCo sample application data.
This object exists for least-privilege permission testing.
EOF
}


# ------------------------------------------------------------
# CloudWatch Log Group
# ------------------------------------------------------------

resource "aws_cloudwatch_log_group" "application" {
  name              = "/startupco/application"
  retention_in_days = 7

  tags = {
    Environment = "production"
  }
}


# ------------------------------------------------------------
# Useful outputs
# ------------------------------------------------------------
