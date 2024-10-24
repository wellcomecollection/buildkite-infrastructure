module "archivematica_infrastructure" {
  source = "./pipeline"

  name        = "archivematica-infrastructure"
  description = "Our custom build of Archivematica and associated infrastructure"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "aws_account_infrastructure" {
  source = "./pipeline"

  name = "aws-account-infrastructure"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "buildkite_infrastructure" {
  source = "./pipeline"

  name = "buildkite-infrastructure"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "catalogue_api" {
  source = "./pipeline"

  name            = "Catalogue API"
  description     = "Catalogue API - Search, Items, Snapshot & Requesting services"
  repository_name = "catalogue-api"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "catalogue_api_deploy_prod" {
  source = "./pipeline"

  name            = "Catalogue API: Deploy prod"
  repository_name = "catalogue-api"

  pipeline_filename = ".buildkite/pipeline.deploy-prod.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "catalogue_api_deploy_stage" {
  source = "./pipeline"

  name            = "Catalogue API: Deploy stage"
  repository_name = "catalogue-api"

  pipeline_filename = ".buildkite/pipeline.deploy-stage.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "catalogue_api_rank" {
  source = "./pipeline"

  name            = "Catalogue API: rank"
  description     = "Run search quality tests against the catalogue API"
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

  name            = "Catalogue Pipeline"
  description     = "Catalogue Pipeline & adapter services"
  repository_name = "catalogue-pipeline"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "catalogue_pipeline_deploy_pipeline" {
  source = "./pipeline"

  name              = "Catalogue Pipeline: Deploy pipeline"
  repository_name   = "catalogue-pipeline"
  pipeline_filename = ".buildkite/pipeline.deploy-pipeline.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "concepts_pipeline" {
  source = "./pipeline"

  name            = "Concepts Pipeline"
  repository_name = "concepts-pipeline"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "content_api" {
  source = "./pipeline"

  name            = "Content API"
  repository_name = "content-api"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "elasticsearch_log_forwarder" {
  source = "./pipeline"

  name            = "Elasticsearch Log Forwarder"
  repository_name = "elasticsearch-log-forwarder"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "identity" {
  source = "./pipeline"

  name            = "Identity"
  description     = "Identity services for Wellcome Collection users"
  repository_name = "identity"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "identity_deployment" {
  source = "./pipeline"

  name            = "Identity Deployment"
  repository_name = "identity"

  pipeline_filename = ".buildkite/pipeline.deploy.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "identity_deploy_prod" {
  source = "./pipeline"

  name            = "Identity: Deploy Prod"
  repository_name = "identity"

  pipeline_filename = ".buildkite/pipeline.deploy-prod.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "identity_deploy_stage" {
  source = "./pipeline"

  name            = "Identity: Deploy Stage"
  repository_name = "identity"

  pipeline_filename = ".buildkite/pipeline.deploy-stage.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "platform_infrastructure" {
  source = "./pipeline"

  name            = "Platform infrastructure"
  repository_name = "platform-infrastructure"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "platform_infrastructure_redirects" {
  source = "./pipeline"

  name            = "Platform Infrastructure: Redirects"
  repository_name = "platform-infrastructure"

  pipeline_filename = ".buildkite/pipeline.redirectsTest.yml"

  schedules = [
    {
      label    = "Hourly redirect tests"
      cronline = "0 * * * *"
    }
  ]
}

module "rank_cli" {
  source = "./pipeline"

  name            = "Rank CLI"
  repository_name = "rank"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "storage_service" {
  source = "./pipeline"

  name            = "Storage Service"
  repository_name = "storage-service"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "storage_service_deploy_prod" {
  source = "./pipeline"

  name            = "Storage Service: deploy prod"
  repository_name = "storage-service"

  pipeline_filename = ".buildkite/pipeline.deploy-prod.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "storage_service_deploy_stage" {
  source = "./pipeline"

  name            = "Storage Service: deploy stage"
  repository_name = "storage-service"

  pipeline_filename = ".buildkite/pipeline.deploy-stage.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "none"
}

module "terraform_modules" {
  source = "./pipeline"

  for_each = toset([
    "terraform-aws-acm-certificate",
    "terraform-aws-api-gateway-responses",
    "terraform-aws-ecs-service",
    "terraform-aws-lambda",
    "terraform-aws-secrets",
    "terraform-aws-sns-topic",
    "terraform-aws-sqs",
  ])

  name            = "Terraform module (${each.key})"
  repository_name = each.key

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "wc_dot_org_build_plus_test" {
  source = "./pipeline"

  name            = "wc.org: build + test"
  description     = "Tests for the wellcomecollection.org repository"
  repository_name = "wellcomecollection.org"

  pipeline_filename = ".buildkite/pipeline.yml"
}

module "wc_dot_org_deployment" {
  source = "./pipeline"

  name            = "wc.org: deployment"
  description     = "Deployments for the web apps in the wellcomecollection.org repo"
  repository_name = "wellcomecollection.org"

  pipeline_filename = ".buildkite/pipeline.deployment.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger at the end of the "build + test" pipeline on main.
  trigger_builds_on = "deployment"
}

module "wc_dot_org_end_to_end_tests" {
  source = "./pipeline"

  name            = "wc.org: end-to-end tests"
  description     = "end-to-end tests to verify the website is working correctly"
  repository_name = "wellcomecollection.org"

  pipeline_filename = ".buildkite/pipeline.e2e-universal.yml"

  # We don't want to trigger this build from pushes or pull requests --
  # it's trigger by the "deployment" pipeline.
  trigger_builds_on = "none"
}

module "wellcome_library_redirects" {
  source = "./pipeline"

  name            = "Wellcome Library: Redirects"
  repository_name = "wellcomelibrary.org"

  pipeline_filename = ".buildkite/pipeline.redirectsTest.yml"

  schedules = [
    {
      label    = "Hourly redirect tests"
      cronline = "0 * * * *"
    }
  ]
}

module "wellcome_library_repo_tests" {
  source = "./pipeline"

  name            = "Wellcome Library: repo tests"
  repository_name = "wellcomelibrary.org"

  pipeline_filename = ".buildkite/pipeline.yml"
}
