resource "aws_iam_role" "this" {
  name               = format("%s%s", var.resource_static_name, "_ec2_role")
  tags               = merge(var.tags, { "Name" = format("%s%s", var.resource_static_name, "_ec2_role") })
  path               = "/local/services/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "SSM"
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid       = "EC2"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:ModifyInstanceAttribute",
      "ec2:DescribeTags",
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = format("%s%s", var.resource_static_name, "_policy")
  path   = "/local/services/"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = format("%s%s", var.resource_static_name, "_inst_profile")
  role = aws_iam_role.this.name
}
