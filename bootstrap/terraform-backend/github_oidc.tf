resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:rosekamdoum36/financial-sre-platform:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "financial-sre-github-actions-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Project   = "financial-sre-platform"
    Purpose   = "github-actions"
    ManagedBy = "terraform"
  }
}