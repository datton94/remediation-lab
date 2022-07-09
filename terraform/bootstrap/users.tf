locals {
  devops = [
    {
    "arn": aws_iam_user.devops_datton.arn
    "name": aws_iam_user.devops_datton.name
    }
  ]
}

############# DEVOPS MEMBERS ##############

resource "aws_iam_user" "devops_datton" {
  name          = "dattonnt94"
  force_destroy = true

  tags = {
    GitHub = "datton94"
    Office = "Saigon"
    Team   = "DevOps"
  }
}

resource "aws_iam_group_membership" "devops_group_membership" {
  group = aws_iam_group.devops.id
  name  = aws_iam_group.devops.name
  users = [ for user in local.devops: user.name ]
}
