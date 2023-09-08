module "catalogue_api" {
  source = "./pipeline"

  name        = "Catalogue API"
  description = "Catalogue API - Search, Items, Snapshot & Requesting services"

  repository_name = "catalogue-api"

  pipeline_filename = ".buildkite/pipeline.yml"
}

moved {
  from = buildkite_pipeline.catalogue_api
  to   = module.catalogue_api.buildkite_pipeline.pipeline
}
