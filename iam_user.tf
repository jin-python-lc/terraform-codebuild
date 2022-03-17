resource "aws_iam_user" "iam_user" {
    for_each = var.iam_users
    name = each.value.name
    path = "/"
    tags = merge(local.tags, map("Name", "${local.system_name}-user"))
}