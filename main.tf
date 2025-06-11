locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "existing" {
  url = local.github_oidc_url
}

resource "aws_iam_openid_connect_provider" "github" {
  count = length(data.aws_iam_openid_connect_provider.existing.url) == 0 ? 1 : 0
  url = local.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = var.thumbrint
}

# Assumed role for the ecr role
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        length(data.aws_iam_openid_connect_provider.existing.arn) == 0 ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.existing.arn
      ]
      type        = "Federated"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_repos
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [
        "sts.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "access" {
  name               = "${var.prefix}GithubAccessReposRole"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "github_role_registry_policy" {
  role       = aws_iam_role.access.name
  policy_arn = var.policy_arn
}