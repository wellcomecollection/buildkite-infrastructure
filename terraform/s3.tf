locals {
  principals = formatlist("arn:aws:iam::%s:root", local.account_ids)
}

resource "aws_s3_bucket" "buildkite_secrets" {
  bucket = "wellcomecollection-buildkite-secrets"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.buildkite_secrets_logging.id
  }
}

resource "aws_s3_bucket" "buildkite_secrets_logging" {
  bucket = "wellcomecollection-buildkite-secrets-logging"
  acl    = "private"
}

resource "aws_s3_bucket" "buildkite_artifacts" {
  bucket = "wellcomecollection-buildkite-artifacts"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "infra" {
  bucket = local.infra_bucket_id
  policy = data.aws_iam_policy_document.infra.json
}

data "aws_iam_policy_document" "infra" {
  statement {
    actions = [
      "s3:*",
    ]

    principals {
      identifiers = local.principals
      type        = "AWS"
    }

    resources = [
      "${local.infra_bucket_arn}/lambdas/*",
      "${local.infra_bucket_arn}/releases/*",
    ]
  }
}
