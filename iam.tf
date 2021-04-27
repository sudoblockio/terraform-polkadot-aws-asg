resource "aws_iam_instance_profile" "api_asg" {
  count       = var.iam_instance_profile == "" ? 1 : 0
  name_prefix = title(local.name)
  role        = join("", aws_iam_role.api_asg.*.name)
}

resource "aws_iam_role" "api_asg" {
  count              = var.iam_instance_profile == "" ? 1 : 0
  name_prefix        = title(local.name)
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "describe_policy" {
  count  = var.iam_instance_profile == "" ? 1 : 0
  policy = join("", data.aws_iam_policy_document.describe_policy.*.json)
}

data "aws_iam_policy_document" "describe_policy" {
  count = var.iam_instance_profile == "" ? 1 : 0
  statement {
    actions   = ["ec2:DescribeInstances"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "api_asg" {
  count      = var.iam_instance_profile == "" ? 1 : 0
  policy_arn = join("", aws_iam_policy.describe_policy.*.arn)
  role       = join("", aws_iam_role.api_asg.*.id)
}
