resource "aws_iam_instance_profile" "this" {
  name = "node_describe_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = "node_describe_role"
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

resource "aws_iam_role_policy_attachment" "external_dns" {
  policy_arn = aws_iam_policy.describe_policy.arn
  role       = aws_iam_role.this.id
}

resource "aws_iam_policy" "describe_policy" {
  policy = data.aws_iam_policy_document.describe_policy.json
}

data "aws_iam_policy_document" "describe_policy" {
  statement {
    actions   = ["ec2:DescribeInstances"]
    effect    = "Allow"
    resources = ["*"]
  }
}
