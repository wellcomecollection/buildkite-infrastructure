# Upload an agent environment hook to /env in the secrets bucket.
#
# This will be downloaded by the agent before the start of each job.
# The hook cleans up the environment, so any stale state left from a previous
# job shouldn't pollute the job that's running now.
#
# See:
# https://github.com/buildkite/elastic-ci-stack-for-aws#build-secrets
# https://buildkite.com/docs/agent/v3/hooks
locals {
  buildkite_agent_hook_path = "${path.module}/../buildkite_agent_hook.sh"
}

resource "aws_s3_bucket_object" "agent_hook" {
  bucket = aws_s3_bucket.buildkite_secrets.id
  key    = "env"
  source = local.buildkite_agent_hook_path
  etag   = filemd5(local.buildkite_agent_hook_path)
}
