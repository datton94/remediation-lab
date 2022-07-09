output "kms_id" {
  value = aws_kms_key.terraform-bootstrap.key_id
}

output "devops_group_arn" {
  value = aws_iam_group.devops.arn
}

output "devops_role_arn" {
  value = aws_iam_role.devops.arn
}

output "devops_arn" {
  value = { for user in local.devops: user.name => user.arn }
}
