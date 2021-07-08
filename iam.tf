resource "aws_iam_role" "this" {
  count              = var.iam_instance_profile == "" ? 1 : 0
  name_prefix        = title(local.name)
  assume_role_policy = data.aws_iam_policy_document.assume_policy_document.json
}

resource "aws_iam_instance_profile" "this" {
  count       = var.iam_instance_profile == "" ? 1 : 0
  name_prefix = title(local.name)
  role        = join("", aws_iam_role.this.*.name)
}

data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sot_bucket_read" {
  count = var.sync_bucket_arn != "" ? 1 : 0

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${var.sync_bucket_arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [var.sync_bucket_arn]
  }
}

resource "aws_iam_policy" "sot_read" {
  count  = var.sync_bucket_arn != "" ? 1 : 0
  policy = join("", data.aws_iam_policy_document.sot_bucket_read.*.json)
}

resource "aws_iam_role_policy_attachment" "sot_read" {
  count      = var.sync_bucket_arn != "" ? 1 : 0
  policy_arn = join("", aws_iam_policy.sot_read.*.arn)
  role       = join("", aws_iam_role.this.*.name)
}

data "aws_iam_policy_document" "sot_kms_key_read" {
  count = var.sync_bucket_arn != "" ? 1 : 0
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [var.sync_bucket_kms_key_arn]
  }
}

resource "aws_iam_policy" "sot_kms_decrypt" {
  count  = var.sync_bucket_kms_key_arn != "" ? 1 : 0
  policy = join("", data.aws_iam_policy_document.sot_bucket_read.*.json)
}

resource "aws_iam_role_policy_attachment" "sot_kms_decrypt" {
  count      = var.sync_bucket_kms_key_arn != "" ? 1 : 0
  policy_arn = join("", aws_iam_policy.sot_kms_decrypt.*.arn)
  role       = join("", aws_iam_role.this.*.name)
}

data "aws_iam_policy_document" "describe_policy" {
  count = var.consul_enabled ? 1 : 0
  statement {
    actions   = ["ec2:DescribeInstances"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "describe_policy" {
  count  = var.consul_enabled ? 1 : 0
  policy = join("", data.aws_iam_policy_document.describe_policy.*.json)
}

resource "aws_iam_role_policy_attachment" "describe_policy" {
  count      = var.consul_enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.describe_policy.*.arn)
  role       = join("", aws_iam_role.this.*.id)
}
