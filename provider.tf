provider "aws" {
    region = "ap-northeast-1"
    assusme_role {
        role_arn = "arn:aws:iam::${var.aws.account_id}:role/StsAdminRole"
    }
}