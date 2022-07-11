resource "aws_iam_group" "devops" {
  name = "devops-terraform-lab"
  path = "/devops-terraform-lab/"
}

resource "aws_iam_group_policy" "devops_policy" {
  name   = "devops_policy"
  group  = aws_iam_group.devops.name
  policy = data.aws_iam_policy_document.devops-assume-role-policy.json
}

resource "aws_iam_role" "devops" {
  name               = "devops-terraform-lab"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.devops-role-allow-assume.json
}

resource "aws_iam_role_policy" "devops" {
  name   = "devops-role-policy"
  role   = aws_iam_role.devops.id
  policy = data.aws_iam_policy_document.devops-role-policy.json
}

data "aws_iam_policy_document" "devops-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::438723512299:role/devops-terraform-lab",
    ]
  }
}

# Define what user/service have permission to execute the AssumeRole action is needed
# We have a Role and we should define what user/service can assume that role
# Note: "group" is not a valid principals
data "aws_iam_policy_document" "devops-role-allow-assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"
      identifiers = [
        for user in local.devops : "arn:aws:iam::438723512299:user/${user.name}"
      ]
    }
  }
}

# We define what devops role can do here

data "aws_iam_policy_document" "devops-role-policy" {
  statement {
    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}
