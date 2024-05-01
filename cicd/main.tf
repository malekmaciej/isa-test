terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "850480876735-demo-tfstate"
    key     = "cicd.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "dor11"
}

data "aws_iam_policy_document" "trust" {
  statement {
    sid    = "TrustGitHub"
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::850480876735:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:malekmaciej/isa-test:*"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "github_actions_demo" {
  name               = "github-actions-demo"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.github_actions_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}