module "catalogue_api" {
  source = "./pipeline"

  name        = "Catalogue API"
  description = "Catalogue API - Search, Items, Snapshot & Requesting services"

  repository_name = "catalogue-api"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "catalogue_api_rank" {
  source = "./pipeline"

  name        = "Catalogue API: rank"
  description = "Run search quality tests against the catalogue API"

  repository_name = "catalogue-api"

  pipeline_filename = ".buildkite/pipeline.rank.yml"

  schedules = [
    {
      label    = "Hourly rank tests"
      cronline = "0 * * * *"
    }
  ]
}

module "catalogue_pipeline" {
  source = "./pipeline"

  name        = "Catalogue Pipeline"
  description = "Catalogue Pipeline & adapter services"

  repository_name = "catalogue-pipeline"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "storage_service" {
  source = "./pipeline"

  name = "Storage Service"

  repository_name = "storage-service"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "wc_dot_org_build_plus_test" {
  source = "./pipeline"

  name        = "wc.org: build + test"
  description = "Tests for the wellcomecollection.org repository"

  repository_name = "wellcomecollection.org"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "wc_dot_org_deployment" {
  source = "./pipeline"

  name        = "wc.org: deployment"
  description = "Deployments for the web apps in the wellcomecollection.org repo"

  repository_name = "wellcomecollection.org"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  github_trigger_mode = "none"

  pipeline_filename = ".buildkite/pipeline.deployment.yml"
}

module "wc_dot_org_end_to_end_tests" {
  source = "./pipeline"

  name        = "wc.org: end-to-end tests"
  description = "end-to-end tests to verify the website is working correctly"

  repository_name = "wellcomecollection.org"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger by the "deployment" pipeline.
  github_trigger_mode = "none"

  pipeline_filename = ".buildkite/pipeline.e2e-universal.yml"
}
