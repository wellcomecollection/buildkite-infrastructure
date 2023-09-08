resource "buildkite_pipeline" "catalogue_api" {
  name = "Catalogue API"
  repository = "git@github.com:wellcomecollection/catalogue-api.git"
  steps = <<EOF
steps:
  - command: "buildkite-agent pipeline upload .buildkite/pipeline.yml"
    label: ":pipeline:"
    agents:
      queue: nano
EOF
  description = "Catalogue API - Search, Items, Snapshot & Requesting services"

  default_branch = "main"

  skip_intermediate_builds = true
  skip_intermediate_builds_branch_filter = "!main"

  allow_rebuilds = true

  cancel_intermediate_builds = true
  cancel_intermediate_builds_branch_filter = "!main"

  provider_settings {
    build_pull_requests = true
    skip_pull_request_builds_for_existing_commits = true

    build_branches = true

    publish_commit_status = true

    publish_blocked_as_pending = true

    trigger_mode = "code"
  }
}