resource "buildkite_pipeline" "pipeline" {
  name       = var.name
  repository = "git@github.com:wellcomecollection/${var.repository_name}.git"

  steps = <<EOF
steps:
  - command: "buildkite-agent pipeline upload ${var.pipeline_filename}"
    label: ":pipeline:"
    agents:
      queue: nano
EOF

  description = var.description

  default_branch = var.default_branch

  # When a new build is created on a branch, any previous builds that
  # haven't yet started on the same branch will be automatically marked
  # as skipped – unless you're on the default branch.
  #
  # Similarly, any previous builds that have already started on the same
  # branch will be skipped.
  skip_intermediate_builds = true
  skip_intermediate_builds_branch_filter = "!${var.default_branch}"

  cancel_intermediate_builds = true
  cancel_intermediate_builds_branch_filter = "!${var.default_branch}"

  # ALlow rebuilds within this pipeline.
  allow_rebuilds = true

  provider_settings {
    # Trigger builds when code is pushed to GitHub.
    trigger_mode = "code"

    # Run builds when branches are pushed or pull requests are created.
    build_branches      = true
    build_pull_requests = true

    # Skip creating a build for a pull request if an existing build for
    # the commit and branch already exist.
    skip_pull_request_builds_for_existing_commits = true

    # Update the status of commits on GitHub.
    publish_commit_status = true

    # Show blocked builds in GitHub as 'pending'.
    publish_blocked_as_pending = true
  }
}

resource "buildkite_pipeline_schedule" "schedule" {
  for_each = {
    for index, schedule in var.schedules :
    schedule.label => schedule.cronline
  }

  pipeline_id = buildkite_pipeline.pipeline.id
  branch      = buildkite_pipeline.pipeline.default_branch

  label    = each.key
  cronline = each.value
}
