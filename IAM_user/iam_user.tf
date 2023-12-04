resource "aws_iam_user" "admin-user" {
    name = "anwar-2"
    tags = {
      Description = "Test user for Terraform"
    }
}

resource "aws_iam_policy" "iam-policy" {
    name = "admin-policy"
    policy = "${file("admin-policy.json")}"
}

resource "aws_iam_user_login_profile" "login-profile" {
    user              = aws_iam_user.admin-user.name
    password_length        = 8
    password_reset_required = true
}

resource "aws_iam_user_policy_attachment" "anwar-admin-access" {
    user = aws_iam_user.admin-user.name
    policy_arn = aws_iam_policy.iam-policy.arn
}

output "login_profile" {
    value = aws_iam_user_login_profile.login-profile.password
}
