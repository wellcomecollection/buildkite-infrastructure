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
