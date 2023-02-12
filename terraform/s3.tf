locals {
  principals = formatlist("arn:aws:iam::%s:root", local.account_ids)
}

resource "aws_s3_bucket" "buildkite_secrets" {
  bucket = "wellcomecollection-buildkite-secrets"
}

resource "aws_s3_bucket_acl" "buildkite_secrets" {
  bucket = aws_s3_bucket.buildkite_secrets.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "buildkite_secrets" {
  bucket        = aws_s3_bucket.buildkite_secrets.id
  target_bucket = aws_s3_bucket.buildkite_secrets_logging.id
  target_prefix = ""
}

resource "aws_s3_bucket" "buildkite_secrets_logging" {
  bucket = "wellcomecollection-buildkite-secrets-logging"
}

resource "aws_s3_bucket_acl" "buildkite_secrets_logging" {
  bucket = aws_s3_bucket.buildkite_secrets_logging.id
  acl    = "log-delivery-write"
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
