data "aws_iam_policy_document" "get_buildkite_agent_key" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:${local.aws_region}:${local.account_id}:parameter/aws/reference/secretsmanager/builds/buildkite_agent_key",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:builds/buildkite_agent_key*",
    ]
  }
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.account_ci_role_arn_map["platform"],
      local.account_ci_role_arn_map["catalogue"],
      local.account_ci_role_arn_map["digirati"],
      local.account_ci_role_arn_map["storage"],
      local.account_ci_role_arn_map["experience"],
      local.account_ci_role_arn_map["workflow"],
      local.account_ci_role_arn_map["identity"],
    ]
  }

  # Deploy images to ECR (platform account)
  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      "*",
    ]
  }

  # Retrieve build secrets
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:builds/*",

      # Allow BuildKite to get rank cluster credentials so it can run tests
      # https://buildkite.com/wellcomecollection/catalogue-api-rank
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:elasticsearch/rank/*",

      # Allow BuildKite to get Prismic API keys to GET/PUT Prismic Custom Types
      # in the Experience build
      # https://buildkite.com/wellcomecollection/experience
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:prismic-model/ci/*",
    ]
  }

  # Publish & retrieve lambdas
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "${local.infra_bucket_arn}/lambdas/*",
    ]
  }
}

data "aws_iam_policy_document" "ci_scala_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.account_ci_role_arn_map["platform"],
      local.account_ci_role_arn_map["catalogue"],
      local.account_ci_role_arn_map["digirati"],
      local.account_ci_role_arn_map["storage"],
      local.account_ci_role_arn_map["experience"],
      local.account_ci_role_arn_map["workflow"],
      local.account_ci_role_arn_map["identity"],
    ]
  }

  # Deploy images to ECR (platform account)
  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      "*",
    ]
  }

  # Retrieve build secrets
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:builds/*",
    ]
  }

  statement {
    actions = [
      "s3:PutObject*",
    ]

    resources = [
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/*",
    ]
  }
}

data "aws_iam_policy_document" "ci_nano_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.account_ci_role_arn_map["platform"],
      local.account_ci_role_arn_map["catalogue"],
      local.account_ci_role_arn_map["digirati"],
      local.account_ci_role_arn_map["storage"],
      local.account_ci_role_arn_map["experience"],
      local.account_ci_role_arn_map["workflow"],
      local.account_ci_role_arn_map["identity"],
    ]
  }

  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      "*",
    ]
  }

  # Retrieve build secrets
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:builds/*",

      # Allow BuildKite to get read-only credentials for the pipeline
      # cluster, to help with auto-deployment of the pipeline.
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:elasticsearch/pipeline_storage_*/read_only*",

      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:elasticsearch/pipeline_storage_*/public_host*",

      # Allow BuildKite to get storage service credentials so it can send
      # test bags in the storage service repo.
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:buildkite/storage_service*",
    ]
  }

  # Deploy static assets in the experience account
  # See https://github.com/wellcomecollection/wellcomecollection.org/tree/main/assets
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::i.wellcomecollection.org",
      "arn:aws:s3:::i.wellcomecollection.org/*",
    ]
  }
}