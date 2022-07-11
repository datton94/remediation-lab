locals {
  spectators = [
    {
    "arn": aws_iam_user.spectator.arn
    "name": aws_iam_user.spectator.name
    },
  ]
}

############# SPECTATORS ##############

resource "aws_iam_user" "spectator" { 
  name          = "spectator"
  force_destroy = true

  tags = {
    GitHub = "n/a"
    Office = "n/a"
    Team   = "n/a"
  }
}

data "aws_iam_policy_document" "spectator" {

  statement {
    sid       = "ListAllkmsAlias"
    effect    = "Allow"
    resources = [
      "*"
      #"arn:aws:kms:ap-southeast-1:438723512299:key/*"
    ]

    actions = [
      "kms:List*",
      "kms:Get*"
    ]
  }

  statement {
    sid       = "Decryptkms"
    effect    = "Allow"
    resources = [
      aws_kms_alias.terraform-bootstrap.arn
    ]

    actions = [
      "kms:*",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
  }

  statement {
    sid       = "ListAllS3buckets"
    effect    = "Allow"
    resources = [
      "arn:aws:s3:::*"
    ]

    actions = ["s3:ListAllMyBuckets"]
  }

  statement {
    sid       = "ListS3bucket"
    effect    = "Allow"
    resources = [
      aws_s3_bucket.terraform.arn
    ]

    actions = ["s3:ListBucket","s3:ListAllMyBuckets"]
  }

  statement {
    sid       = "GetS3objects"
    effect    = "Allow"
    resources = [
      "${aws_s3_bucket.terraform.arn}/*"
    ]

    actions = ["s3:GetObject"]
  }

  statement {
    sid       = "ViewEksCluster"
    effect    = "Allow"
    resources = [
      "*"
    ]

    actions = [
      "eks:List*",
      "eks:Describe*",
    ]
  }

  statement {
    sid       = "ViewCloudWatch"
    effect    = "Allow"
    resources = [
      "arn:aws:logs:ap-southeast-1:438723512299:log-group:*"
    ]

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
    ]
  }
}

resource "aws_iam_user_policy" "spectator" {
  name = "spectator"
  user = aws_iam_user.spectator.name

  policy = data.aws_iam_policy_document.spectator.json
}
